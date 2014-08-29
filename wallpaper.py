#!/usr/bin/python3

import random
import os
import signal
import subprocess
import sys
import time

if len(sys.argv) < 2:

  print("Too few arguments")
  sys.exit()

def kill_others():

    pid = os.getpid()
    others = subprocess.getoutput("pgrep wallpaper.py").split("\n")
    for other in others:

        if int(other) != int(pid):

            os.kill(int(other), signal.SIGTERM)

def load_arguments():

    image_folders = []
    for i, folder in enumerate(sys.argv):

        if i == 1:

            time = folder
        else:

            image_folders.append(folder)
    return (time, image_folders)

def generate_image_pool(image_folders):

    image_pool = []
    for folder in image_folders:

        for path, subdirs, files in os.walk(folder):

            for name in files:

                extension = name[-3:]
                if extension == "jpg":

                    image_pool.append(os.path.join(path,name))
    return image_pool

def random_image(image_pool):

    number = random.randint(0,len(image_pool))
    return image_pool[number]

def set_background(image):

    command = "feh --bg-fill {0}".format(image)
    subprocess.getoutput(command)
    set_lockscreen(image)

def set_lockscreen(image):

    extension = image[-3:]
    if extension == "jpg":

        command = "convert {0} /tmp/lockscreen.png".format(image)
    else:

        command = "cp {0} /tmp/lockscreen.png".format(image)
    subprocess.getoutput(command)

        

def main():

    kill_others()
    delay, image_folders = load_arguments()
    image_pool = generate_image_pool(image_folders)
    image = random_image(image_pool)
    set_background(image)
    while True:

        time.sleep(int(delay))
        image = random_image(image_pool)
        set_background(image)

if __name__ == "__main__":

    main()
