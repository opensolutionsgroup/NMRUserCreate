#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

read -p "Enter the new users name: " username
username=${username,,}

echo "Checking and Deleting user, $username"
cd /home/$username

tree -dL 2 /home/${username,}
cat ./fstab.add
echo ""


if [ -f "/home/${username,}/fstab.add" ]; then
	read -r -p "Shall I update the /etc/fstab to remove persistant mounts [Y/n] " response
	
	if [[ "$response" =~ ([yY])$ ]]; then
		diff /etc/fstab ./fstab.add  > fstab.patch	# create difference patch to remove addeded fstab entries
		patch -R ./fstab.new ./fstab.patch		# create new fstab file from patch
		cp /etc/fstab /etc/fstab.orig			# copy fstab.patch to backup version
		cp ./fstab.new /etc/fstab			# copy fstab.new with patched version
		echo "/etc/fstab HAS been modified"
        else
		echo "/etc/fstab HAS NOT been modified"
	fi
fi

echo "Deleting Mount Point Directories"
echo "# Deleted [ $username ] NMRUserDelete-Mount on $(date '+%A, %d %B %Y, %T')" >> ~/fstab.deleted

if [ -d "/var/www/html/Raw-Files/300B/${username[@]^}/nmr" ]; then
	umount /home/${username,}/NMRData/300B
	echo "/var/www/html/Raw-Files/300B/${username[@]^}/nmr /home/${username,}/NMRData/300B none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/300B
elif [ -d "/var/www/html/Raw-Files/300B/${username,}/nmr" ]; then
	umount /home/${username,}/NMRData/300B
	echo "/var/www/html/Raw-Files/300B/${username,}/nmr /home/${username,}/NMRData/300B none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/300B
fi

if [ -d "/var/www/html/Raw-Files/300BIconNMR/${username[@]^}/nmr" ]; then
	umount /home/${username,}/NMRData/300BIconNMR
	echo "/var/www/html/Raw-Files/300BIconNMR/${username[@]^}/nmr /home/${username,}/NMRData/300BIconNMR none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/300BIconNMR
elif [ -d "/var/www/html/Raw-Files/300BIconNMR/${username,}/nmr" ]; then
	umount /home/${username,}/NMRData/300BIconNMR
	echo "/var/www/html/Raw-Files/300BIconNMR/${username,}/nmr /home/${username,}/NMRData/300BIconNMR none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/300BIconNMR
fi

if [ -d "/var/www/html/Raw-Files/500/${username[@]^}/nmr" ]; then
	umount /home/${username,}/NMRData/500
	echo "/var/www/html/Raw-Files/500/${username[@]^}/nmr /home/${username,}/NMRData/500 none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/500

elif [ -d "/var/www/html/Raw-Files/500/${username,}/nmr" ]; then
	umount /home/${username,}/NMRData/500
	echo "/var/www/html/Raw-Files/500/${username,}/nmr /home/${username,}/NMRData/500 none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/500
fi

if [ -d "/var/www/html/Raw-Files/Ascend300/Data/${username[@]^}" ]; then
	umount /home/${username,}/NMRData/Ascend300
	echo "/var/www/html/Raw-Files/Ascend300/Data/${username[@]^} /home/${username,}/NMRData/Ascend300 none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/Ascend300
elif [ -d "/var/www/html/Raw-Files/Ascend300/Data/${username,}" ]; then
	umount /home/${username,}/NMRData/Ascend300
	echo "/var/www/html/Raw-Files/Ascend300/Data/${username,} /home/${username,}/NMRData/Ascend300 none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/Ascend300
fi

if [ -d "/var/www/html/Raw-Files/NEO600/Data/${username[@]^}" ]; then
	umount /home/${username,}/NMRData/NEO600
	echo "/var/www/html/Raw-Files/NEO600/Data/${username[@]^} /home/${username,}/NMRData/NEO600 none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/NEO600
elif [ -d "/var/www/html/Raw-Files/NEO600/Data/${username,}" ]; then
	umount /home/${username,}/NMRData/NEO600
	echo "/var/www/html/Raw-Files/NEO600/Data/${username,} /home/${username,}/NMRData/NEO600 none bind 0 0" >> ~/fstab.deleted
	rmdir NMRData/NEO600
fi

# Prepare to delete home direcotory
rmdir /home/$username/NMRData
cd /home

# Remote $username from sftpgroup
deluser $username sftpgroup

# Remove $username and delete home directory
deluser --remove-home $username

echo "Completed Deleting user, $username"
