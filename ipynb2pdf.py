#!/usr/bin/python3
"""Author:      Olivier van der Toorn <oliviervdtoorn@gmail.com>
Description:    Converts ipython notebooks to pdf"""

import subprocess
import os
import sys

for i in range(1, len(sys.argv)):
    path = sys.argv[i]
    filename = path.replace('.ipynb', '')
    command = ["ipython", "nbconvert", "--to", "latex", "{0}".format(path), "--stdout"]
    converter = subprocess.Popen(command, stdout=subprocess.PIPE)
    pdflatex = subprocess.Popen('pdflatex', stdout=subprocess.PIPE, stdin=converter.stdout)
    converter.stdout.close()
    output = pdflatex.communicate()[0]

    os.rename('texput.pdf', '{0}.pdf'.format(filename))
    rm = subprocess.Popen(['rm', 'texput.aux', 'texput.log', 'texput.out'])

