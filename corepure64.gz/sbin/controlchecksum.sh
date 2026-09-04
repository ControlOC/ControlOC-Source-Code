#!usr/bin/bash
KEY="$(cat /var/installer/controlchecksum.ctrlcheck)"
MD5_ROOT="$(sudo find / -type f ! -name controlchecksum.ctrlcheck ! -path /init ! -path /initrd.image ! -path '*/etc/*' ! -path '*/opt/*' ! -path '*/root/*' ! -path '*/mnt/*' ! -path '*/home/*' ! -path '*/sys/*' ! -path '*/proc/*' ! -path '*/dev/*' ! -path '*/tmp/*' -print0 | sudo xargs -0 md5sum | sudo md5sum | sudo awk '{print $1}')"
if [ "$KEY" = "$MD5_ROOT" ]; then
	echo "true"
	echo "root: $MD5_ROOT"
	echo "key: $KEY"
else
	echo "false"
	echo "root: $MD5_ROOT"
	echo "key: $KEY"
fi
