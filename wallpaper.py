#!/usr/bin/python3

import random
import os
import signal
import socket
import select
import subprocess
import sys
import time

def too_few_arguments(num):

  if len(sys.argv) < num+1:

    print("Too few arguments")
    sys.exit()

def kill_others():

    pid = os.getpid()
    others = subprocess.getoutput("pgrep wallpaper.py").split("\n")
    for other in others:

        if other != '' and int(other) != int(pid):

            os.kill(int(other), signal.SIGTERM)

def load_arguments():

    too_few_arguments(1)
    mode = 'start'
    try:

      int(sys.argv[1])
    except:

      mode = 'change'
    if mode == 'start':

      too_few_arguments(2)
      image_folders = []
      for i, folder in enumerate(sys.argv):

          if i == 1:

              delay = int(folder)
          else:

              image_folders.append(folder)
    else:

      delay = 0
      image_folders = ''
    return (mode, delay, image_folders)

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

def get_width():

    command = "xrandr|grep \*|awk '{print $1}'"
    resolution = subprocess.getoutput(command).split('x')[0]
    return resolution

def set_background(image):

    command = "feh --bg-fill {0}".format(image)
    subprocess.getoutput(command)
    set_lockscreen(image)

def set_lockscreen(image):

    resolution = get_width()
    extension = image[-3:]
    if extension == "jpg":

        command = "convert -resize {0} {1} /tmp/lockscreen.png".format(resolution, image)
    else:

        command = "cp {0} /tmp/lockscreen.png".format(image)
    print(command)
    subprocess.getoutput(command)

def handler():

  global sock
  sock  = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  sock.bind(('127.0.0.1', 1025))
  sock.setblocking(0)

def receive():

  global sock
  result = select.select([sock],[],[], 5)
  if result[0]:

    data, addr = result[0][0].recvfrom(1024)
    try:

      data_string = str(data,'utf-8').replace('\n','')
      if data_string == 'change':

        print("Changing")
        global image_pool
        image = random_image(image_pool)
        set_background(image)
        global time_change
        time_change = 0
    except:

      pass

def send(data):

  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  sock.sendto(data, ('127.0.0.1', 1025))

def change():

  running = False
  pid = os.getpid()
  others = subprocess.getoutput("pgrep wallpaper.py").split("\n")
  for other in others:

      if other != '' and int(other) != int(pid):

        running = True
        break
  if running == False:

    print("Wallpaper manager not running please start it!")
    sys.exit()
  data = bytes("change", 'utf-8')
  send(data)

def main():

    mode, delay, image_folders = load_arguments()
    if mode == 'start':

      kill_others()
      global image_pool
      image_pool = generate_image_pool(image_folders)
      image = random_image(image_pool)
      set_background(image)

      global wait_time
      wait_time = int(delay/10)
      handler()

      global time_change
      time_change = 0
      while True:

          if time_change == 0:

            time_change = time.time() + int(delay)
          if time.time() > time_change:

            image = random_image(image_pool)
            set_background(image)
            time_change = 0
          else:

            receive()
    else:

      change()

if __name__ == "__main__":

    main()
