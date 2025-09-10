#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

read -p "Enter the new users name: " username
username=${username,,}

echo "Checking and Creating user, $username"

# Adduser $username and add to group sftpgroup
adduser $username
#deluser --remove-home $username

usermod -aG sftpgroup $username
#deluser $username sftpgroup

# Setting up for chroot for sftpuser group
chown root /home/$username
chmod go-w /home/$username

echo "Creating Mount Point Directories"
cd /home/$username

mkdir NMRData
chown $username:$username NMRData

echo "Creating Mount Points"
echo "# Added [ $username ] NMRUserCreate-Mount on $(date '+%A, %d %B %Y, %T')" > fstab.add

if [ -d "/var/www/html/Raw-Files/300B/${username[@]^}/nmr" ]; then
	mkdir NMRData/300B
	mount --bind /var/www/html/Raw-Files/300B/${username[@]^}/nmr /home/${username,}/NMRData/300B
	echo "/var/www/html/Raw-Files/300B/${username[@]^}/nmr /home/${username,}/NMRData/300B none bind 0 0" >> fstab.add
elif [ -d "/var/www/html/Raw-Files/300B/${username,}/nmr" ]; then
	mkdir NMRData/300B
	mount --bind /var/www/html/Raw-Files/300B/${username,}/nmr /home/${username,}/NMRData/300B
	echo "/var/www/html/Raw-Files/300B/${username,}/nmr /home/${username,}/NMRData/300B none bind 0 0" >> fstab.add
fi

if [ -d "/var/www/html/Raw-Files/300BIconNMR/${username[@]^}/nmr" ]; then
	mkdir NMRData/300BIconNMR
	mount --bind /var/www/html/Raw-Files/300BIconNMR/${username[@]^}/nmr /home/${username,}/NMRData/300BIconNMR
	echo "/var/www/html/Raw-Files/300BIconNMR/${username[@]^}/nmr /home/${username,}/NMRData/300BIconNMR none bind 0 0" >> fstab.add
elif [ -d "/var/www/html/Raw-Files/300BIconNMR/${username,}/nmr" ]; then
	mkdir NMRData/300BIconNMR
	mount --bind /var/www/html/Raw-Files/300BIconNMR/${username,}/nmr /home/${username,}/NMRData/300BIconNMR
	echo "/var/www/html/Raw-Files/300BIconNMR/${username,}/nmr /home/${username,}/NMRData/300BIconNMR none bind 0 0" >> fstab.add
fi

if [ -d "/var/www/html/Raw-Files/500/${username[@]^}/nmr" ]; then
	mkdir NMRData/500
	mount --bind /var/www/html/Raw-Files/500/${username[@]^}/nmr /home/${username,}/NMRData/500
	echo "/var/www/html/Raw-Files/500/${username[@]^}/nmr /home/${username,}/NMRData/500 none bind 0 0" >> fstab.add
elif [ -d "/var/www/html/Raw-Files/500/${username,}/nmr" ]; then
	mkdir NMRData/500
	mount --bind /var/www/html/Raw-Files/500/${username,}/nmr /home/${username,}/NMRData/500
	echo "/var/www/html/Raw-Files/500/${username,}/nmr /home/${username,}/NMRData/500 none bind 0 0" >> fstab.add
fi

if [ -d "/var/www/html/Raw-Files/Ascend300/Data/${username[@]^}" ]; then
	mkdir NMRData/Ascend300
	mount --bind /var/www/html/Raw-Files/Ascend300/Data/${username[@]^} /home/${username,}/NMRData/Ascend300
	echo "/var/www/html/Raw-Files/Ascend300/Data/${username[@]^} /home/${username,}/NMRData/Ascend300 none bind 0 0" >> fstab.add
elif [ -d "/var/www/html/Raw-Files/Ascend300/Data/${username,}" ]; then
	mkdir NMRData/Ascend300
	mount --bind /var/www/html/Raw-Files/Ascend300/Data/${username,} /home/${username,}/NMRData/Ascend300
	echo "/var/www/html/Raw-Files/Ascend300/Data/${username,} /home/${username,}/NMRData/Ascend300 none bind 0 0" >> fstab.add
fi

if [ -d "/var/www/html/Raw-Files/NEO600/Data/${username[@]^}" ]; then
	mkdir NMRData/NEO600
	mount --bind /var/www/html/Raw-Files/NEO600/Data/${username[@]^} /home/${username,}/NMRData/NEO600
	echo "/var/www/html/Raw-Files/NEO600/Data/${username[@]^} /home/${username,}/NMRData/NEO600 none bind 0 0" >> fstab.add
elif [ -d "/var/www/html/Raw-Files/NEO600/Data/${username,}" ]; then
	mkdir NMRData/NEO600
	mount --bind /var/www/html/Raw-Files/NEO600/Data/${username,} /home/${username,}/NMRData/NEO600
	echo "/var/www/html/Raw-Files/NEO600/Data/${username,} /home/${username,}/NMRData/NEO600 none bind 0 0" >> fstab.add
fi

tree -dL 2 /home/${username,}
cat ./fstab.add
echo ""

read -r -p "Shall I update the /etc/fstab to make mounts persistant [y/N] " response
if [[ "$response" =~ ^([yY])$ ]]; then
	echo "/etc/fstab HAS been modified"
	cat ./fstab.add >> /etc/fstab 
else
	echo "/etc/fstab HAS NOT been modified"
fi

