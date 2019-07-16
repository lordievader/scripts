#!/usr/bin/python3
import os
import sys
import exifread
import re
import datetime
import shutil
import logging

GPHOTO=["/mnt/multimedia/photos/Phone/",
        "/home/lordievader/GoogleDrive/Google Photos/"]
DNG=["/mnt/multimedia/photos/DNG-import/",
     "/home/lordievader/GoogleDrive/dng/"]
EXIFKEY="Image DateTime"
EXIFKEY_ALT="EXIF DateTime"

MOVE=True


def move(src, dst):
    """Moves a file from src to dst.

    :param src: source file
    :type src: string
    :param dst: destination
    :type dst: string
    """
    logging.info("moving %s --> %s", src, dst)
    date_path = os.path.split(dst)[0]
    if MOVE is True:
        if os.path.isdir(date_path) is False:
            os.makedirs(date_path)

        shutil.move(src, dst)

def delete(src):
    """Deletes a file if MOVE is true

    :param src: path to file to delete
    :type src: str
    """
    logging.info('deleting "%s"', src)
    if MOVE is True:
        os.remove(src)

def key_move(DIR, tags, photo, year_dir=None):
    """Move a photo based on their exif data.

    :param DIR: the base directory
    :type DIR: string
    :param tags: the exif tags
    :type tags: dictionary
    :param year_dir: the path to the year
    :type year_dir: string
    :param photo: path to the photo
    :type photo: string
    """
    exifkey = EXIFKEY
    if EXIFKEY not in tags:
        exifkey = EXIFKEY_ALT

    date = datetime.datetime.strptime(str(tags[exifkey]), "%Y:%m:%d %H:%M:%S")
    date_path = os.path.join(DIR, str(date.year), str(date.month), str(date.day))
    if year_dir is not None:
        src = os.path.join(year_dir, photo)

    else:
        src = os.path.join(DIR, photo)

    dst = os.path.join(date_path, photo)
    move(src, dst)


def name_move(DIR, year_dir, photo):
    """Move a photo based on its name.

    :param DIR: the base directory
    :type DIR: string
    :param year_dir: the path to the year
    :type year_dir: string
    :param photo: path to the photo
    :type photo: string
    """
    date = datetime.datetime.strptime(re.search(r'[0-9]{8}', photo).group(0),
            "%Y%m%d")
    date_path = os.path.join(DIR, str(date.year), str(date.month), str(date.day))
    src = os.path.join(year_dir, photo)
    dst = os.path.join(date_path, photo)
    move(src, dst)



def main_gphoto():
    """Scans the photos for their date and puts them in the correct folder.
    """
    for DIR in GPHOTO:  # Get both the src and dst dir in the same shape
        for year in os.listdir(DIR):
            year_dir = os.path.join(DIR, year)
            os.chdir(year_dir)
            for photo in os.listdir(year_dir):
                if not photo.endswith('DNG') and os.path.isfile(photo):
                    with open(os.path.join(year_dir, photo), 'rb') as f:
                        tags = exifread.process_file(f)
                        if EXIFKEY in tags or EXIFKEY_ALT in tags:
                            key_move(DIR, tags, photo, year_dir)

                        elif re.search('IMG-[0-9]{8}-WA', photo):
                                name_move(DIR, year_dir, photo)

def main_dng():
    """Sorts the DNG files and puts them in the import directory.
    """
    for dng_dir in DNG:
        for photo in os.listdir(dng_dir):
            if photo.endswith('DNG'):
                with open(os.path.join(dng_dir, photo), 'rb') as f:
                    tags = exifread.process_file(f)
                    if EXIFKEY in tags:
                        key_move(dng_dir, tags, photo)
            
            elif ('GoogleDrive' in dng_dir and 
                  os.path.isfile(os.path.join(dng_dir,photo))):
                delete(os.path.join(dng_dir, photo))


def main():
    """Calls the other mains.
    """
    main_gphoto()
    main_dng()


if __name__ == '__main__':
    logging.basicConfig(level=logging.WARNING)
    main()
