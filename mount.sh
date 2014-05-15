#!/bin/bash
address="corellian-corvette.mini.true"

function loadKey {
    fingerprint=$(ssh-add -l|awk '{print $2}'|head -n1)
    if [ $fingerprint == "47:80:fa:a9:3d:d8:a1:26:65:92:c7:92:1b:31:27:12" ] || [ $fingerprint == "1f:8f:1e:f1:8a:bb:67:9e:69:e2:e6:1d:a3:15:ad:d3" ]; then
        echo "Key loaded"
    else
        echo "Key not loaded"
        ssh-add
    fi
}

function nfsMount {
    echo NFS
    echo
    
    unmount

    echo lordievader
    sudo mount corellian-corvette.mini.true:/home/lordievader	/media/lordievader

    echo Movies
    sudo mount corellian-corvette.mini.true:/media/Movies		/media/Movies

    echo Music
    sudo mount corellian-corvette.mini.true:/media/Music		/media/Music

    echo Storage
    sudo mount corellian-corvette.mini.true:/media/Storage		/media/Storage

    echo Web
    sudo mount corellian-corvette.mini.true:/var/www/			/media/Web

    echo Anime
    sudo mount corellian-corvette.mini.true:/media/Anime		/media/Anime

}

function smbMount {
    echo Samba
    echo

    kdesudo ls

    unmount

    echo "Please enter your Samba password:"
    read -s password

    echo lordievader
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/lordievader /media/lordievader

    echo Movies
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Movies /media/Movies

    echo Music
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Music /media/Music

    echo Storage
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Storage /media/Storage

    echo Web
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Web /media/Web

    echo Anime
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Anime /media/Anime
}

function sshfsMount {
    echo SSHFS
    echo

    unmount

    loadKey
    
    echo lordievader 
    sshfs -o idmap=user,ServerAliveInterval=15 lordievader@lordievader.no-ip.org:/home/lordievader /media/lordievader

    echo Movies
    sshfs -o idmap=user,ServerAliveInterval=15 lordievader@lordievader.no-ip.org:/media/Movies   /media/Movies

    echo Music
    sshfs -o idmap=user,ServerAliveInterval=15 lordievader@lordievader.no-ip.org:/media/Music    /media/Music

    echo Storage
    sshfs -o idmap=user,ServerAliveInterval=15 lordievader@lordievader.no-ip.org:/media/Storage  /media/Storage

    echo Web
    sshfs -o idmap=user,ServerAliveInterval=15 lordievader@lordievader.no-ip.org:/var/www    /media/Web

    echo Anime
    sshfs -o idmap=user,ServerAliveInterval=15 lordievader@lordievader.no-ip.org:/media/Anime    /media/Anime
}

function unmount {
  
    mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
    if [ $mountpoint ]; then
   
        mounttype=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $1; }'|sed 's/:[^:]*$//')

        if [ $mounttype == "lordievader@lordievader.no-ip.org" ]; then
            echo SSHFS

            mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
            while [ $mountpoint ]; do
                echo $mountpoint
                fusermount -zu $mountpoint
                mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
            done

        elif [ $(echo $mounttype | grep -e "localhost") ]; then
            echo SMBFS

            mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
            while [ $mountpoint ]; do
                echo $mountpoint
                sudo umount $mountpoint
                mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
            done

        else
            echo NFS

            mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
            while [ $mountpoint ]; do
                echo $mountpoint
                sudo umount $mountpoint
                mountpoint=$(mount|grep -e "lordievader.no-ip.org" -e "corellian-corvette.mini.true" -e "localhost"|head -n 1|awk '{ print $3; }')
            done
        fi
    fi
}

##  Main loop
if [ -z $1 ]; then
	echo "  Kasui mount script
        Usage: nfs [options]

		-m		mount directories
        -u      unmount directories"

elif [ $1 == "-m" ]; then
	if ping -q -c1 corellian-corvette.mini.true; then
        nfsMount

	else
        #smbMount
        sshfsMount
	fi

elif [ $1 == "-u" ]; then
    unmount
elif [ $1 == "-k" ]; then
    loadKey
fi
