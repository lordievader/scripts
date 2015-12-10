#!/usr/bin/python3
import os
import re
import subprocess
import sys

#test = '[ebuild   R    ] dev-vcs/tig-2.0.3::gentoo  USE="unicode" 0 KiB'
#print(re.search('(\[ebuild.*?\])\ (.*?)\ .*', test).group(2))
#raise SystemExit()

email_to = 'oliviervdtoorn@gmail.com'

command = 'eix-sync -q'
output = subprocess.getoutput(command)

command = '/usr/bin/emerge --pretend --deep --nospinner world'
packages = subprocess.getoutput(command).split('\n')
not_installed = []
build = []
for package in packages:
    if re.search('ebuild', package):
        package = re.search('(\[ebuild.*?\])\ (.*?)\ .*', package)
        if package:
            header = package.group(1)
            package = package.group(2)
            #print("package: {0}".format(package))
            if package != '' and 'U' in header:
                package = re.sub(':.*$', '', package)
                #print("subbed: {0}".format(package))
                category = package.split('/')[0]
                package = package.split('/')[1]
                #print((category, package))

                path = '/usr/portage/packages/%s/%s.tbz2' % (category, package)
                if os.path.isfile(path):
                    not_installed.append('%s/%s' % (category, package))

                else:
                    build.append('%s/%s' % (category, package))

if len(build) == 0 and len(not_installed) == 0:
    raise SystemExit()

build_packages = " =".join(build)
build_output = []
command = '/usr/bin/emerge --buildpkgonly \
--oneshot --nospinner --keep-going =%s' % build_packages
process = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE,
                           stdout=subprocess.PIPE, bufsize=1)
for line in iter(process.stdout.readline, b''):
    line = str(line, 'utf-8').replace("\n", "")
    build_output.append(line)

build_output = "\n".join(build_output)
build = " \=".join(build)
not_installed = " \=".join(not_installed)
mail = ['Subject: Preliminary World Update - Millenium-Falcon',
        'To: oliviervdtoorn@gmail.com',
        'From: Cron Daemon <root@millenium-falcon>',
        '']
if len(not_installed) > 0:
    mail.append('Binary packages can be installed with: emerge -K <package-name>')
    mail.append('Available binary packages for install are:')
    mail.append('\=' + not_installed)
    mail.append('')

if len(build) > 0:
    mail.append('Following packages were built:')
    mail.append('\=' + build)
    mail.append('')

if len(build_output) > 0:
    mail.append('The following is build output:')
    mail.append('')
    mail.append(build_output)

mail = "\n".join(mail)
with open('/tmp/gupdate.mail', 'w') as temp_file:
    temp_file.write(mail)

#print(mail)
command = 'cat /tmp/gupdate.mail | msmtp -a default %s' % email_to
output = subprocess.getoutput(command)
#print(output)
