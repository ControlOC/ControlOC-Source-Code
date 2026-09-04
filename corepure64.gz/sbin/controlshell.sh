#!/usr/bin/bash
controlchecksum="true" #controlchecksum=$(sudo sh /sbin/controlchecksum.sh)
while true; do
	COUNT=$((COUNT + 1))
	if [ ! "$COUNT" = "40" ]; then
		echo " "
	else
		break
	fi
done
sudo touch /tmp/history_controlshell
sudo chmod 666 /tmp/history_controlshell
if [ "$controlchecksum" = "false" ]; then
	echo "      / \\"
	echo "     /   \\"
	echo "    /  |  \\"
	echo "   /   |   \\"
	echo "  /         \\"
	echo " /     O     \\"
	echo "/_____________\\"
	echo " "
	echo "System has detected non official files in system directory. Please sure if system is installed correctly. Your system is unlocked to malwares and other utils."
	while true; do
		read -r -p "Type C to continue, or type off to turn off your computer: " MODIFIED
		if [ "$MODIFIED" = "C" ] || [ "$MODIFIED" = "c" ]; then
			break
		else
			if [ ! "$MODIFIED" = "off" ]; then
				echo "Wrong word."
			else
				sudo poweroff
				break
			fi
		fi
	done
fi
printf "ControlOC v0.25 \n Hey, there! This is ControlOC, and here you can do everything. \n To download this OC, open browser, and go to link 'https://controloc.vercel.app', and download it. \n This OC don't have support for Russian language. \n To show all commands, type 'help'. To see all writen commands fully, type 'show' to open showing mode. \n \n \n \n"
while true; do
	if [ -f /opt/cs_dir ]; then
		if [ ! "$(cat /opt/cs_dir)" = "/" ]; then
			CS_DIR="$(cat /opt/cs_dir)"
			cd "$CS_DIR" || cd /
		else
			CS_DIR="root:/"
			cd /
		fi
	else
		CS_DIR="root:/"
	fi
	if [ -f /tmp/terminal_admin ]; then
		if [ "$controlchecksum" = "true" ]; then
			printf "ADMIN %s >> \n" "$CS_DIR" | tee -a /tmp/history_controlshell
		else
			printf "Modified. ADMIN %s >> \n" "$CS_DIR" | tee -a /tmp/history_controlshell
		fi
		read -r cmd args
		echo "$cmd $args" >> /tmp/history_controlshell
		printf "\n" >> /tmp/history_controlshell
		if [ "$cmd" = "admin" ]; then
			sudo rm /tmp/terminal_admin
		elif [ "$cmd" = "show" ]; then
			less /tmp/history_controlshell
		elif [ "$cmd" = "reboot" ]; then
			sudo reboot
		elif [ "$cmd" = "turnoff" ]; then
			sudo poweroff
		elif [ "$cmd" = "setpassword" ] && [ -n "$args" ]; then
			if [ ! -f /opt/passwd ]; then
				echo "$args" > /opt/passwd
				read -r -p "Please, write this password again to verify: " PASSWD
				if [ "$PASSWD" = "$args" ]; then
					echo "Setted up password" | tee -a /tmp/history_controlshell
				else
					echo "Wrong password. Try again to set password" | tee -a /tmp/history_controlshell
					rm /opt/passwd
				fi
			else
				read -r -p "Write your old password: " OLD_PASSWD
				if [ "$OLD_PASSWD" = "$(cat /opt/passwd)" ]; then
					read -r -p "Please, write new password again to verify: " NEW_PASSWDD
					if [ "$NEW_PASSWDD" = "$args" ]; then
						echo "$NEW_PASSWDD" > /opt/passwd
						echo "Setted up password." | tee -a /tmp/history_controlshell
					else
						echo "Wrong password. Try again" | tee -a /tmp/history_controlshell
					fi
				else
					echo "Sorry, wrong password." | tee -a /tmp/history_controlshell
				fi
			fi
		elif [ "$cmd" = "cd" ]; then
			if [ -n "$args" ]; then
				if [ -d "$args" ]; then
					echo "Going to directory '$args'..." | tee -a /tmp/history_controlshell
					echo "$args" > "/opt/cs_dir"
				else
					if [ -f "$args" ]; then
						echo "This is a file" | tee -a /tmp/history_controlshell
					else
						echo "No such directory '$args'" | tee -a /tmp/history_controlshell
					fi
				fi
			else
				cat /opt/cs_dir | tee -a /tmp/history_controlshell
			fi
		elif [ "$cmd" = "exit" ]; then
			sudo poweroff
			break
		elif [ "$cmd" = "help" ]; then
			controlscript.sh --helpforshell | tee -a /tmp/history_controlshell
			continue
		elif [ "$cmd" = "fingerprint" ]; then
			cat /var/fingerprint | tee -a /tmp/history_controlshell
			ARG=$(awk '{print $1}' /var/fingerprint | tr -d '\n')
			ARG2=$(awk '{print $2}' /var/fingerprint | tr -d '\n')
			ARG3=$(awk '{print $3}' /var/fingerprint | tr -d '\n')
			ARG4=$(awk '{print $4}' /var/fingerprint | tr -d '\n')
			echo "$ARG is a version of ControlOC" | tee -a /tmp/history_controlshell
			echo "$ARG2 is a generation of ControlOC" | tee -a /tmp/history_controlshell
			echo "$ARG3 is how many times the build was rebuilt of ControlOC" | tee -a /tmp/history_controlshell
			echo "$ARG4 is date of build" | tee -a /tmp/history_controlshell
			continue
		elif [ "$cmd" = "linux" ]; then
			sudo $args | tee -a /tmp/history_controlshell
		else
			echo "$cmd $args" > "/tmp/ckrnl_code.cs"
			sudo controlscriptrun.sh -Rf "/tmp/ckrnl_code.cs" | tee -a /tmp/history_controlshell
			continue
		fi
	else
		if [ "$controlchecksum" = "true" ]; then
			printf "controlshell %s >> \n" "$CS_DIR" | tee -a /tmp/history_controlshell
		else
			printf "Modified. controlshell %s >> \n" "$CS_DIR" | tee -a /tmp/history_controlshell
		fi
		read -r cmd args
		echo "$cmd $args" >> /tmp/history_controlshell
		printf "\n" >> /tmp/history_controlshell
		if [ "$cmd" = "admin" ]; then
			if [ -f /opt/passwd ]; then
				read -r -p "Write password: " OLD_PASSWD
				if [ "$OLD_PASSWD" = "$(cat /opt/passwd)" ]; then
					touch /tmp/terminal_admin
				else
					echo "Wrong password!" | tee -a /tmp/history_controlshell
				fi
			else
				touch /tmp/terminal_admin
			fi
		elif [ "$cmd" = "show" ]; then
			less /tmp/history_controlshell
		elif [ "$cmd" = "reboot" ]; then
			sudo reboot
		elif [ "$cmd" = "turnoff" ]; then
			sudo poweroff
		elif [ "$cmd" = "setpassword" ] && [ -n "$args" ]; then
			if [ ! -f /opt/passwd ]; then
				echo "$args" > /opt/passwd
				read -r -p "Please, write this password again to verify: " PASSWD
				if [ "$PASSWD" = "$args" ]; then
					echo "Setted up password" | tee -a /tmp/history_controlshell
				else
					echo "Wrong password. Try again to set password" | tee -a /tmp/history_controlshell
					rm /opt/passwd
				fi
			else
				read -r -p "Write your old password: " OLD_PASSWD
				if [ "$OLD_PASSWD" = "$(cat /opt/passwd)" ]; then
					read -r -p "Please, write new password again to verify: " NEW_PASSWDD
					if [ "$NEW_PASSWDD" = "$args" ]; then
						echo "$NEW_PASSWDD" > /opt/passwd
						echo "Setted up password." | tee -a /tmp/history_controlshell
					else
						echo "Wrong password. Try again" | tee -a /tmp/history_controlshell
					fi
				else
					echo "Sorry, wrong password." | tee -a /tmp/history_controlshell
				fi
			fi
		elif [ "$cmd" = "cd" ]; then
			if [ -n "$args" ]; then
				if [ -d "$args" ]; then
					echo "Going to directory '$args'..." | tee -a /tmp/history_controlshell
					echo "$args" > "/opt/cs_dir"
				else
					if [ -f "$args" ]; then
						echo "This is a file" | tee -a /tmp/history_controlshell
					else
						echo "No such directory '$args'" | tee -a /tmp/history_controlshell
					fi
				fi
			else
				cat /opt/cs_dir | tee -a /tmp/history_controlshell
			fi
		elif [ "$cmd" = "exit" ]; then
			sudo poweroff
			break
		elif [ "$cmd" = "help" ]; then
			controlscript.sh --helpforshell | tee -a /tmp/history_controlshell
			continue
		elif [ "$cmd" = "fingerprint" ]; then
			cat /var/fingerprint | tee -a /tmp/history_controlshell
			ARG=$(awk '{print $1}' /var/fingerprint | tr -d '.')
			ARG2=$(awk '{print $2}' /var/fingerprint | tr -d '.')
			ARG3=$(awk '{print $3}' /var/fingerprint | tr -d '.')
			ARG4=$(awk '{print $4}' /var/fingerprint | tr -d '.')
			echo "$ARG is a version of ControlOC" | tee -a /tmp/history_controlshell
			echo "$ARG2 is a generation of ControlOC" | tee -a /tmp/history_controlshell
			echo "$ARG3 is how many times the build was rebuilt of ControlOC" | tee -a /tmp/history_controlshell
			echo "$ARG4 is date of build" | tee -a /tmp/history_controlshell
			continue
		elif [ "$cmd" = "linux" ]; then
			su tc -c "$args | tee -a /tmp/history_controlshell"
		else
			echo '$cmd $args' > '/tmp/ckrnl_code.cs'
			su tc -c "controlscriptrun.sh -f /tmp/ckrnl_code.cs | tee -a /tmp/history_controlshell"
			continue
		fi
	fi
done
