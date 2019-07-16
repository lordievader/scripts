#/bin/bash
# Script for finding the lastlogin times of users with uid > 1000.
OLD_IFS=$IFS
IFS=$'\n'
for username in $(getent passwd |grep -v nobody | awk -F: '$3 > 1000{printf "%-10s %5d\n",  $1, $3}'|sort -k2 -n|uniq|cut -f 1 -d ' ');
do
    for line in $(lastlog -b 90 -u $username|grep -v Username);
    do
        name=${line/\ */}
        fullname=$(getent passwd $name|cut -d: -f5)
        if [ -z "$(echo $line|grep -v Never)" ]; then
            date="**Never logged in**"
        else
            date=$(date -I -d "$(echo $line|awk '{print $4 " " $5 " " $6 " " $7 " " $8 " " $9}')")
        fi
        printf "%-50s %s\n" $fullname $date
    done
done
IFS=$OLD_IFS
