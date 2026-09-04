read -p "Write directory of the file you want to install/update: " FILE_DIR
if [ -f "$FILE_DIR" ]; then
	mkdir -p /tmp/installer_tmp
	echo "Processing..."
	tar -xf $FILE_DIR -C /tmp/installer_tmp/
	if [ ! $? -eq 0 ]; then
		echo "Util is not installed. Error: 2. Maybe util is corrupted."
		exit 2
	fi
	if [ -f /tmp/installer_tmp/certificate.ctrlcheck ]; then
		CERT="/tmp/installer_tmp/certificate.ctrlcheck"
	else
		echo "Util don't have a certificate. It can be a mawlare. Error code: 5."
		exit 5
	fi
	SEARCH_DIR="/ckrnl/installed_util/"
	FOUND=0
	while IFS= read -r -d '' file; do
		if [ $file = $CERT ]; then
			FOUND=1
			echo "File is founded. With equal."
			echo "$FOUND"
		fi
		if cmp -s "$CERT" "$file"; then
			FOUND=1
			echo "File is founded."
			echo "$FOUND"
			break
		fi
	done < <(find "$SEARCH_DIR" -maxdepth 1 -type f -print0)
	echo "FOUND = $FOUND"
	if [ -f /tmp/installer_tmp/name_util ] && [ -f /tmp/installer_tmp/name_util_short ]; then
		NAME=$(cat /tmp/installer_tmp/name_util)
		SHORT_NAME=$(cat /tmp/installer_tmp/name_util_short)
	else
		echo "Oops, util is not named. Util is not installed. Error 3."
		exit 3
	fi
	UPDATE=$(printf "$NAME \n Update this util? (yes/no): ")
	INSTALL=$(printf "$NAME \n Install this util? (yes/no): ")
	if [ "$FOUND" = "1" ]; then
		read -p "$UPDATE" ACCEPT
		if [ $ACCEPT = "yes" ]; then
			echo "Updating util..."
			cp -r /tmp/installer_tmp/* /ckrnl/installed_util/${SHORT_NAME}/
			if [ ! $? -eq 0 ]; then
				echo "Installer cannot update util. Try again. Error code 8."
				exit 8
			fi
			echo "Last process..."
			rm -rf /tmp/installer_tmp_data
			rm -rf /tmp/installer_tmp
			cp $FILE_DIR /ckrnl/utils
			if [ $? -eq 0 ]; then
				echo "Util is updated."
			else
				echo "Util can't be updated. Try again. Error code 9."
			fi
		else
			echo "Util is not updated. You didn't accept the permission."
			exit 0
		fi
	else
		read -p "$INSTALL" ACCEPT
		if [ $ACCEPT = "yes" ]; then
			if [ -d /tmp/installer_tmp/data ]; then
				echo "Copying data..."
				mkdir -p /tmp/installer_tmp_data
				cp -r /tmp/installer_tmp/data /tmp/installer_tmp_data
				rm -rf /tmp/installer_tmp/data
				DATA_EXISTING=true
			fi
			echo "Installing util..."
			mkdir -p /ckrnl/installed_util/${SHORT_NAME}
			cp -r /tmp/installer_tmp/* /ckrnl/installed_util/${SHORT_NAME}/
			if [ ! $? -eq 0 ]; then
				echo "Oops, util is not installed. Try to again install. Error code: 6"
				exit 6
			fi
			if [ $DATA_EXISTING = "true" ]; then
				cp -r /tmp/installer_tmp_data/* /ckrnl/util_data/${SHORT_NAME}/
				if [ ! $? -eq 0 ]; then
					echo "Oops, data of util is corrupted. Try again to install. Error code 7."
					exit 7
				fi
			fi
			echo "Last process..."
			rm -rf /tmp/installer_tmp_data
			rm -rf /tmp/installer_tmp
			cp $FILE_DIR /ckrnl/utils
			if [ $? -eq 0 ]; then
				echo "Util is installed."
			else
				echo "Util cannot be installed. Try again. Error code 9."
			fi
		else
			echo "Util is not installed. You didn't accept the permission."
			exit 0
		fi
	fi
else
	if [ ! -d $FILE_DIR ]; then
		echo "File is not existing. Error 1."
		exit 1
	else
		echo "This is a directory. Wrong file. Error 4."
		exit 4
	fi
fi
