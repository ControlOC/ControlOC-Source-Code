#!/usr/bin/bash
if [ ! -f "$2" ]; then
	echo "Error: '$2': No such file or file not readable"
	exit 1
fi
if [ "$1" = "-f" ] && [ -f "$2" ]; then
	SCRIPT="$2"
	COMMANDS=("create" "delete" "move" "copy" "rename" "write" "linux" "folder" "#value" "display" "if" "calculate" "cycle" "ifend" "ckrnl")
	COUNT_COMMANDS="${#COMMANDS[@]}"
	LINE_NUM=0
	while IFS= read -r LINE; do
		KNOWN=false
		LINE_NUM=$((LINE_NUM + 1))
		LINE_CLEAN=$(echo $LINE | tr -d '\r')
		for i in {1..50}; do eval "ARG$i=\"\""; done
		CMD=""
		ARG_COUNT=0
		while read -r ARGS; do
			if [ -z "$CMD" ]; then
				CMD=$ARGS
			else
				ARG_COUNT=$((ARG_COUNT + 1))
				eval "ARG$ARG_COUNT=\"$ARGS\""
			fi
		done <<< "$(echo $LINE_CLEAN | xargs printf "%s\n")"
		ARGUMENT=$(echo "$LINE" | sed 's/.*"\(.*\)".*/\1/')
		COUNT_KNOWN="0"
		for KNOWN_CMD in "${COMMANDS[@]}"; do
			COUNT_KNOWN=$(($COUNT_KNOWN + 1))
			if [ "$CMD" = "$KNOWN_CMD" ]; then
				KNOWN=true
				if [ -n "$ARG1" ]; then
					if [ "$CMD" = "ckrnl" ]; then
						ROOT=true
					fi
					if [ "$CMD" = "create" ]; then
						touch "$ARG1"
						if [ $? -eq 0 ]; then
							echo "Added new file: $ARG1"
						else
							echo "Error: Could not add file '$ARG1'"
						fi
					fi
					if [ "$CMD" = "folder" ]; then
						if [ -n "$ARG1" ]; then
							mkdir -p $ARG1
							if [ $? -eq 0 ]; then
								echo "Added a folder: $ARG1"
							else
								echo "Error: Could not add a folder '$ARG1'"
							fi
						else
							echo "Error: Can't create folder ' ', the name of the folder is empty."
						fi
					fi
					if [ "$CMD" = "delete" ]; then
						rm -rf "$ARG1"
						if [ $? -eq 0 ]; then
							echo "Deleted file or directory: $ARG1"
						else
							echo "Error: Could not delete file or directory '$ARG1'"
						fi
					fi
					if [ "$CMD" = "move" ]; then
						if [ -n "$ARG2" ]; then
							mv "$ARG1" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Moved file $ARG1 to the $ARG2"
							else
								echo "Error: Could not move file '$ARG1'"
							fi
						fi
					fi
					if [ "$CMD" = "copy" ]; then
						if [ -n "$ARG2" ]; then
							cp "$ARG1" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Copied file: $ARG1 to $ARG2"
							else
								echo "Error: Could not copy file '$ARG1' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "rename" ]; then
						if [ -n "$ARG2" ]; then
							mv "$ARG1" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Renamed file: $ARG1 to $ARG2"
							else
								echo "Error: Could not rename file '$ARG1' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "display" ]; then
						if [ ! "$ARG1" = "-directory" ]; then
							if [ ! "$ARG1" = "-file" ]; then
								echo "$ARG1"
								if [ ! $? -eq 0 ]; then
									echo "Error: Could not display text '$ARG1'."
								fi
							fi
						fi
					fi
					if [ "$CMD" = "linux" ]; then
						if [ -n "$ARG1" ]; then
							shift
							$ARGUMENT
						else
							sed -n '/linux/,/linend/p' "$SCRIPT" > /tmp/ckrnl_linux_exec.sh
							sh /tmp/ckrnl_linux_exec.sh
						fi
					fi
					if [ "$CMD" = "cycle" ]; then
						if [ "$ARG1" = "forever" ]; then
							sed -n '/cycle \forever/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle_forever.cs
							while true; do
								controlscriptrun.sh -Rf /tmp/ckrnl_cycle_forever.cs
							done
						else
							sed -n '/cycle $ARG1/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle.cs
							for i in {1..$ARG1}; do
								controlscriptrun.sh -Rf /tmp/ckrnl_cycle.cs
							done
						fi
					fi
					if [ -n "$ARG2" ]; then
						if [ "$CMD" = "display" ]; then
							if [ "$ARG1" = "-file" ]; then
								if [ -f "$ARG2" ]; then
									cat "$ARG2"
								else
									echo "Error: '$ARG2' is not a file, or '$ARG2' not exist or file not readable."
								fi
							fi
							if [ "$ARG1" = "-directory" ]; then
								if [ -d "$ARG2" ]; then
									ls "$ARG2"
								else
									echo "Error: '$ARG2' is not a directory, or '$ARG2' not exist or directory not readable."
								fi
							fi
						fi
						if [ "$CMD" = "write" ]; then
							if [ -f "$ARG2" ]; then
								echo "$ARG1" > "$ARG2"
								if [ $? -eq 0 ]; then
									echo "Writed text '$ARG1' to the: $ARG2"
								else
									echo "Error: Could not write '$ARG1' to file '$ARG2'"
								fi
							else
								echo "Error: No such text file '$ARG2'."
							fi
						fi
						if [ "$CMD" = "#value" ]; then
							if [ -n "$ARG3" ]; then
								echo "$VALUE$VALUE_NUM"
							else
								echo "Syntax Error: Line '$LINE_NUM': No enough arguments, to set value, write: '#value COUNT 1"
							fi
						fi
						if [ -n "$ARG3" ]; then
							if [ -n "$ARG4" ]; then
								if [ "$CMD" = "if" ]; then
									if [ ! "$ARG3" = "!" ]; then
										if [ "$ARG4" = "=" ]; then
											if [ "$ARG2" = "$ARG4" ]; then
												sed -n '/if \[/,/ifend/p' "$SCRIPT" > /tmp/ckrnl_if.cs
												controlscriptrun.sh -Rf /tmp/ckrnl_if.cs
											fi
										fi
									fi
								fi
							fi
							if [ "$CMD" = "calculate" ]; then
								if [ ! -n "$ARG4" ]; then
									CALCULATE="$ARG1 $ARG2 $ARG3"
									ANSWER="$(($CALCULATE))"
									echo "$ANSWER"
								fi
							fi
						fi
					fi
				fi
				break
			else
				if (( COUNT_KNOWN > COUNT_COMMANDS )); then
					if [ -f "/ckrnl/utils/${CMD}.cutil" ]; then
						echo "$ARGUMENT" > "/ckrnl/installed_util/${CMD}/cmd.cs"
						if [ ! -f /ckrnl/installed_util/${CMD}/sh_start ]; then
							controlscriptrun.sh -f "/ckrnl/installed_util/${CMD}/util_start.cs"
						else
							sh "$(cat /ckrnl/installed_util/${CMD}/util_start_sh.sh)"
						fi
					else
						echo "No such command '$CMD'."
						break
					fi
				fi
			fi
		done
	done < "$SCRIPT"
	if [ -f /tmp/ckrnl_code.cs ]; then
		#rm /tmp/ckrnl_code.cs
	fi
	if [ -f /tmp/ckrnl_if.cs ]; then
		#rm /tmp/ckrnl_if.cs
	fi
	if [ -f /tmp/ckrnl_cycle.cs ]; then
		#rm /tmp/ckrnl_cycle.cs
	fi
	if [ -f /tmp/ckrnl_cycle_forever.cs ]; then
		#rm /tmp/ckrnl_cycle_forever.cs
	fi
fi
if [ "$1" = "-Rf" ] && [ -f "$2" ]; then
	SCRIPT="$2"
	COMMANDS=("create" "delete" "move" "copy" "rename" "write" "linux" "folder" "#value" "display" "if" "calculate" "cycle" "ifend" "ckrnl")
	COUNT_COMMANDS="${#COMMANDS[@]}"
	LINE_NUM=0
	while IFS= read -r LINE; do
		KNOWN=false
		LINE_NUM=$((LINE_NUM + 1))
		LINE_CLEAN=$(echo $LINE | tr -d '\r')
		for i in {1..50}; do eval "ARG$i=\"\""; done
		CMD=""
		ARG_COUNT=0
		while read -r ARGS; do
			if [ -z "$CMD" ]; then
				CMD=$ARGS
			else
				ARG_COUNT=$((ARG_COUNT + 1))
				eval "ARG$ARG_COUNT=\"$ARGS\""
			fi
		done <<< "$(echo $LINE_CLEAN | xargs printf "%s\n")"
		ARGUMENT=$(echo "$LINE" | sed 's/.*"\(.*\)".*/\1/')
		COUNT_KNOWN="0"
		for KNOWN_CMD in "${COMMANDS[@]}"; do
			COUNT_KNOWN=$(($COUNT_KNOWN + 1))
			if [ "$CMD" = "$KNOWN_CMD" ]; then
				KNOWN=true
				if [ -n "$ARG1" ]; then
					if [ "$CMD" = "ckrnl" ]; then
						ROOT=true
					fi
					if [ "$CMD" = "create" ]; then
						sudo touch "$ARG1"
						if [ $? -eq 0 ]; then
							echo "Added new file: $ARG1"
						else
							echo "Error: Could not add file '$ARG1'"
						fi
					fi
					if [ "$CMD" = "folder" ]; then
						if [ -n "$ARG1" ]; then
							sudo mkdir -p $ARG1
							if [ $? -eq 0 ]; then
								echo "Added a folder: $ARG1"
							else
								echo "Error: Could not add a folder '$ARG1'"
							fi
						else
							echo "Error: Can't create folder ' ', the name of the folder is empty."
						fi
					fi
					if [ "$CMD" = "delete" ]; then
						sudo rm -rf "$ARG1"
						if [ $? -eq 0 ]; then
							echo "Deleted file or directory: $ARG1"
						else
							echo "Error: Could not delete file or directory '$ARG1'"
						fi
					fi
					if [ "$CMD" = "move" ]; then
						if [ -n "$ARG2" ]; then
							sudo mv "$ARG1" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Moved file $ARG1 to the $ARG2"
							else
								echo "Error: Could not move file '$ARG1'"
							fi
						fi
					fi
					if [ "$CMD" = "copy" ]; then
						if [ -n "$ARG2" ]; then
							sudo cp -r "$ARG1" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Copied file: $ARG1 to $ARG2"
							else
								echo "Error: Could not copy file '$ARG1' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "rename" ]; then
						if [ -n "$ARG2" ]; then
							sudo mv "$ARG1" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Renamed file: $ARG1 to $ARG2"
							else
								echo "Error: Could not rename file '$ARG1' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "display" ]; then
						if [ ! "$ARG1" = "-directory" ]; then
							if [ ! "$ARG1" = "-file" ]; then
								sudo echo "$ARG1"
								if [ ! $? -eq 0 ]; then
									sudo echo "Error: Could not display text '$ARG1'."
								fi
							fi
						fi
					fi
					if [ "$CMD" = "linux" ]; then
						if [ -n "$ARG1" ]; then
							shift
							sudo $ARGUMENT
						else
							sed -n '/linux/,/linend/p' "$SCRIPT" > /tmp/ckrnl_linux_exec.sh
							sudo sh /tmp/ckrnl_linux_exec.sh
						fi
					fi
					if [ "$CMD" = "cycle" ]; then
						if [ "$ARG1" = "forever" ]; then
							sudo sed -n '/cycle \forever/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle_forever.cs
							while true; do
								sudo controlscriptrun.sh -Rf /tmp/ckrnl_cycle_forever.cs
							done
						else
							sudo sed -n '/cycle $ARG1/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle.cs
							for i in {1..$ARG1}; do
								sudo controlscriptrun.sh -Rf /tmp/ckrnl_cycle.cs
							done
						fi
					fi
					if [ -n "$ARG2" ]; then
						if [ "$CMD" = "display" ]; then
							if [ "$ARG1" = "-file" ]; then
								if [ -f "$ARG2" ]; then
									sudo cat "$ARG2"
								else
									echo "Error: '$ARG2' is not a file, or '$ARG2' not exist or file not readable."
								fi
							fi
							if [ "$ARG1" = "-directory" ]; then
								if [ -d "$ARG2" ]; then
									sudo ls "$ARG2"
								else
									echo "Error: '$ARG2' is not a directory, or '$ARG2' not exist or directory not readable."
								fi
							fi
						fi
						if [ "$CMD" = "write" ]; then
							if [ -f "$ARG2" ]; then
								echo "$ARG1" > "$ARG2"
								if [ $? -eq 0 ]; then
									sudo echo "Writed text '$ARG1' to the: $ARG2"
								else
									sudo echo "Error: Could not write '$ARG1' to file '$ARG2'"
								fi
							else
								sudo echo "Error: No such text file '$ARG2'."
							fi
						fi
						if [ "$CMD" = "#value" ]; then
							VALUE_NUM=$((VALUE_NUM + 1))
							if [ -n "$ARG3" ]; then
								sudo declare "VALUE$VALUE_NUM"="$ARG3"
								sudo echo "$VALUE$VALUE_NUM"
							else
								sudo echo "Syntax Error: Line '$LINE_NUM': No enough arguments, to set value, write: '#value COUNT 1"
							fi
						fi
						if [ -n "$ARG3" ]; then
							if [ -n "$ARG4" ]; then
								if [ "$CMD" = "if" ]; then
									if [ ! "$ARG3" = "!" ]; then
										if [ "$ARG4" = "=" ]; then
											if [ "$ARG2" = "$ARG4" ]; then
												sudo sed -n '/if \[/,/ifend/p' "$SCRIPT" > /tmp/ckrnl_if.cs
												sudo controlscriptrun.sh -Rf /tmp/ckrnl_if.cs
											fi
										fi
									fi
								fi
							fi
							if [ "$CMD" = "calculate" ]; then
								if [ ! -n "$ARG4" ]; then
									CALCULATE="$ARG1 $ARG2 $ARG3"
									ANSWER="$(($CALCULATE))"
									sudo echo "$ANSWER"
								fi
							fi
						fi
					fi
				fi
				break
			else
				if (( COUNT_KNOWN > COUNT_COMMANDS )); then
					if [ -f "/ckrnl/utils/${CMD}.cutil" ]; then
						echo "$ARGUMENT" > "/ckrnl/installed_util/${CMD}/cmd.cs"
						if [ ! -f /ckrnl/installed_util/${CMD}/sh_start ]; then
							sudo controlscriptrun.sh -f "/ckrnl/installed_util/${CMD}/util_start.cs"
						else
							sudo sh "$(cat /ckrnl/installed_util/${CMD}/util_start_sh.sh)"
						fi
					else
						sudo echo "No such command '$CMD'."
						break
					fi
				fi
			fi
		done
	done < "$SCRIPT"
	if [ -f /tmp/ckrnl_code.cs ]; then
		#sudo rm /tmp/ckrnl_code.cs
	fi
	if [ -f /tmp/ckrnl_if.cs ]; then
		#sudo rm /tmp/ckrnl_if.cs
	fi
	if [ -f /tmp/ckrnl_cycle.cs ]; then
		#sudo rm /tmp/ckrnl_cycle.cs
	fi
	if [ -f /tmp/ckrnl_cycle_forever.cs ]; then
		#sudo rm /tmp/ckrnl_cycle_forever.cs
	fi
fi
