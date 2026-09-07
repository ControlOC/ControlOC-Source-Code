if [ "$1" = "--run" ] && [ -n "$2" ]; then
    if [ -f "$2" ]; then
		if [ "$(whoami)" = "root" ]; then
			sudo controlscriptrun.sh -Rf "$2"
		else
			controlscriptrun.sh -f "$2"
		fi
    else
        echo "$2: No such script"
        exit 1
    fi
else
    if [ "$1" = "--help" ]; then
		echo "Commands: "
		echo "--run = Run script in .cs, with LF, use: controlscript.sh --run yourscript.cs"
		echo " "
		echo "--runcode = Run ckrnl code, use: controlscript.sh --runcode create exampe.txt"
	else
		if [ "$1" = "--runcode" ] && [ -n "$2" ]; then
			echo "$2" > "/tmp/ckrnl_code.cs"
			if [ "$(whoami)" = "root" ]; then
				sudo controlscriptrun.sh -Rf /tmp/ckrnl_code.cs
			else
				controlscriptrun.sh -f /tmp/ckrnl_code.cs
			fi
		else
			if [ "$1" = "--helpforshell" ]; then
				echo "Help:"
				echo "_______________"
				echo "Commands:"
				echo "_______________"
				echo "'create' - creates a file"
				echo "'delete' - deletes a file or folder"
				echo "'write' - writes text in a file"
				echo "'display' - shows a text, shows text from file or shows files in folder"
				echo "'move' - moves a file to another directory"
				echo "'copy' - copies a file or directory to other directory"
				echo "'rename' - renames a file"
				echo "'calculate' - calculates a numbers"
				echo "'linux' - runs a linux code"
				echo "'fingerprint' - shows a fingerprint"
				echo "'turnoff'/'reboot' - turns the computer off/rebooting computer"
				echo "'admin' - running commands from ADMINISTRATOR"
				echo "'cd' - will go to this directory"
				echo "'setpassword' - sets the password/resets the password"
				echo "'show' - fully showing logs of commands"
				echo "_______________"
				echo "Usage:"
				echo "_______________"
				echo "create <file> - creates file"
				echo "delete <file or folder> - deletes selected file or directory"
				echo "display <text to show> - shows a text in terminal shell"
				echo "display -directory <directory> - shows files in this directory"
				echo "display -file <file> - shows text in a file"
				echo "write <text> <file> - writes text in a file"
				echo "move <source file> <another directory> - moves file into directory"
				echo "copy <source file> <directory> - copies file into a directory"
				echo "rename <file> <new file> - renames file to new file"
				echo "calculate <first number> <operation, for example: +> <second number> - calculates first number and second number"
				echo "linux <command> - runs <command> in linux enviroment"
				echo "fingerprint - just shows a fingerprint"
				echo "turnoff/reboot - just turning off or restarting PC"
				echo "'admin', after, '<password>' - runs commands from root after writing password, or quiting from this mode."
				echo "cd <dir> - going to directory <dir>"
				echo "setpassword <new password> - sets the password or resets the password"
				echo "show - just fully showing all logs"
				echo "_______________"
				echo "That's end, thanks for reading"
			else
				echo "Syntax error: unexpected '$1', use --help"
				exit 1
			fi
		fi
	fi
fi
