#!/usr/bin/bash
if [ "$1" = "-f" ] && [ -n "$2" ]; then
	SCRIPT="$2"
	COMMANDS=("create" "delete" "move" "copy" "rename" "write"  "#value" "display" "if" "calculate" "cycle" "ifend" "ckrnl")
	LINE_NUM=0
	while IFS= read -r LINE; do
		KNOWN=false
		LINE_NUM=$((LINE_NUM + 1))
		CMD=$(echo "$LINE" | awk '{print $1}' | tr -d '\r')
		ARG=$(echo "$LINE" | awk '{print $2}' | tr -d '\r')
		ARG2=$(echo "$LINE" | awk '{print $3}' | tr -d '\r')
		ARG3=$(echo "$LINE" | awk '{print $4}' | tr -d '\r')
		ARG4=$(echo "$LINE" | awk '{print $5}' | tr -d '\r')
		ARG5=$(echo "$LINE" | awk '{print $6}' | tr -d '\r')
		if [ -n "$ARG5" ]; then
			ARG6=$(echo "$LINE" | awk '{print $7}' | tr -d '\r')
			ARG7=$(echo "$LINE" | awk '{print $8}' | tr -d '\r')
			ARG8=$(echo "$LINE" | awk '{print $9}' | tr -d '\r')
			ARG9=$(echo "$LINE" | awk '{print $10}' | tr -d '\r')
			ARG10=$(echo "$LINE" | awk '{print $11}' | tr -d '\r')
		fi
		if [ -n "$ARG10" ]; then
			ARG11=$(echo "$LINE" | awk '{print $12}' | tr -d '\r')
			ARG12=$(echo "$LINE" | awk '{print $13}' | tr -d '\r')
			ARG13=$(echo "$LINE" | awk '{print $14}' | tr -d '\r')
			ARG14=$(echo "$LINE" | awk '{print $15}' | tr -d '\r')
			ARG15=$(echo "$LINE" | awk '{print $16}' | tr -d '\r')
		fi
		ARGUMENT=$(echo "$LINE" | sed 's/.*"\(.*\)".*/\1/')
		
		for KNOWN_CMD in ${COMMANDS[@]}; do
			if [ "$CMD" = "$KNOWN_CMD" ]; then
				KNOWN=true
				if [ -n "$ARG" ]; then
					if [ "$CMD" = "ckrnl" ]; then
						ROOT=true
					fi
					if [ "$CMD" = "create" ]; then
						touch "$ARG"
						if [ $? -eq 0 ]; then
							echo "Added new file: $ARG"
						else
							echo "Error: Could not add file '$ARG'"
						fi
					fi
					if [ "$CMD" = "delete" ]; then
						rm -rf "$ARG"
						if [ $? -eq 0 ]; then
							echo "Deleted file or directory: $ARG"
						else
							echo "Error: Could not delete file or directoey '$ARG'"
						fi
					fi
					if [ "$CMD" = "move" ]; then
						if [ -n "$ARG2" ]; then
							mv "$ARG" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Moved file $ARG to the $ARG2"
							else
								echo "Error: Could not move file '$ARG'"
							fi
						fi
					fi
					if [ "$CMD" = "copy" ]; then
						if [ -n "$ARG2" ]; then
							cp "$ARG" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Copied file: $ARG to $ARG2"
							else
								echo "Error: Could not copy file '$ARG' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "rename" ]; then
						if [ -n "$ARG2" ]; then
							mv "$ARG" "$ARG2"
							if [ $? -eq 0 ]; then
								echo "Renamed file: $ARG to $ARG2"
							else
								echo "Error: Could not rename file '$ARG' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "display" ]; then
						if [ ! "$ARG" = "-directory" ]; then
							if [ ! "$ARG" = "-file" ]; then
								echo "$ARG"
								if [ ! $? -eq 0 ]; then
									echo "Error: Could not display text '$ARG'."
								fi
							fi
						fi
					fi
					if [ "$CMD" = "cycle" ]; then
						if [ "$ARG" = "forever" ]; then
							sed -n '/cycle \forever/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle_forever.cs
							while true
							do
								controlscriptrun.sh -Rf /tmp/ckrnl_cycle_forever.cs
							done
						else
							sed -n '/cycle \$ARG/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle.cs
							for i in {1..$ARG}
							do
								controlscriptrun.sh -Rf /tmp/ckrnl_cycle.cs
							done
						fi
					fi
					if [ -n "$ARG2" ]; then
						if [ "$CMD" = "display" ]; then
							if [ "$ARG" = "-file" ]; then
								if [ -f "$ARG2" ]; then
									cat "$ARG2"
								else
									echo "Error: '$ARG2' is not a file, or '$ARG2' not exist or file not readable."
								fi
							fi
							if [ "$ARG" = "-directory" ]; then
								if [ -d "$ARG2" ]; then
									ls "$ARG2"
								else
									echo "Error: '$ARG2' is not a directory, or '$ARG2' not exist or directory not readable."
								fi
							fi
						fi
						if [ "$CMD" = "write" ]; then
							if [ -f "$ARG2" ]; then
								echo "$ARG" > "$ARG2"
								if [ $? -eq 0 ]; then
									echo "Writed text '$ARG' to the: $ARG2"
								else
									echo "Error: Could not write '$ARG' to file '$ARG2'"
								fi
							else
								echo "Error: No such text file '$ARG2'."
							fi
						fi
						if [ "$CMD" = "#value" ]; then
							VALUE_NUM=$((VALUE_NUM + 1))
							if [ -n "$ARG3" ]; then
								declare "VALUE$VALUE_NUM"="$ARG3"
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
											if [ "$ARG2" = "ARG4" ]; then
												sed -n '/if \[/,/ifend/p' "$SCRIPT" > /tmp/ckrnl_if.cs
												controlscriptrun.sh -Rf /tmp/ckrnl_if.cs
											fi
										fi
									fi
								fi
							fi
							if [ "$CMD" = "calculate" ]; then
								if [ ! -n "$ARG4" ]; then
									CALCULATE="$ARG $ARG2 $ARG3"
									ANSWER="$(($CALCULATE))"
									echo "$ANSWER"
								fi
							fi
						fi
					fi
				fi
				break
			fi
		done
	done < "$SCRIPT"
	if [ -f /tmp/ckrnl_code.cs ]; then
		rm /tmp/ckrnl_code.cs
	fi
	if [ -f /tmp/ckrnl_if.cs ]; then
		rm /tmp/ckrnl_if.cs
	fi
	if [ -f /tmp/ckrnl_cycle.cs ]; then
		rm /tmp/ckrnl_cycle.cs
	fi
	if [ -f /tmp/ckrnl_cycle_forever.cs ]; then
		rm /tmp/ckrnl_cycle_forever.cs
	fi
fi

if [ "$1" = "-Rf" ] && [ -n "$2" ]; then
	SCRIPT="$2"
	COMMANDS=("create" "delete" "move" "copy" "rename" "write"  "#value" "display" "if" "calculate" "cycle" "ifend" "ckrnl")
	LINE_NUM=0
	while IFS= read -r LINE; do
		KNOWN=false
		LINE_NUM=$((LINE_NUM + 1))
		CMD=$(echo "$LINE" | awk '{print $1}' | tr -d '\r')
		ARG=$(echo "$LINE" | awk '{print $2}' | tr -d '\r')
		ARG2=$(echo "$LINE" | awk '{print $3}' | tr -d '\r')
		ARG3=$(echo "$LINE" | awk '{print $4}' | tr -d '\r')
		ARG4=$(echo "$LINE" | awk '{print $5}' | tr -d '\r')
		ARG5=$(echo "$LINE" | awk '{print $6}' | tr -d '\r')
		if [ -n "$ARG5" ]; then
			ARG6=$(echo "$LINE" | awk '{print $7}' | tr -d '\r')
			ARG7=$(echo "$LINE" | awk '{print $8}' | tr -d '\r')
			ARG8=$(echo "$LINE" | awk '{print $9}' | tr -d '\r')
			ARG9=$(echo "$LINE" | awk '{print $10}' | tr -d '\r')
			ARG10=$(echo "$LINE" | awk '{print $11}' | tr -d '\r')
		fi
		if [ -n "$ARG10" ]; then
			ARG11=$(echo "$LINE" | awk '{print $12}' | tr -d '\r')
			ARG12=$(echo "$LINE" | awk '{print $13}' | tr -d '\r')
			ARG13=$(echo "$LINE" | awk '{print $14}' | tr -d '\r')
			ARG14=$(echo "$LINE" | awk '{print $15}' | tr -d '\r')
			ARG15=$(echo "$LINE" | awk '{print $16}' | tr -d '\r')
		fi
		ARGUMENT=$(echo "$LINE" | sed 's/.*"\(.*\)".*/\1/')
		
		for KNOWN_CMD in ${COMMANDS[@]}; do
			if [ "$CMD" = "$KNOWN_CMD" ]; then
				KNOWN=true
				if [ -n "$ARG" ]; then
					if [ "$CMD" = "ckrnl" ]; then
						ROOT=true
					fi
					if [ "$CMD" = "create" ]; then
						sudo touch "$ARG"
						if [ $? -eq 0 ]; then
							sudo echo "Added new file: $ARG"
						else
							sudo echo "Error: Could not add file '$ARG'"
						fi
					fi
					if [ "$CMD" = "delete" ]; then
						sudo rm -rf "$ARG"
						if [ $? -eq 0 ]; then
							sudo echo "Deleted file or directory: $ARG"
						else
							sudo echo "Error: Could not delete file or directoey '$ARG'"
						fi
					fi
					if [ "$CMD" = "move" ]; then
						if [ -n "$ARG2" ]; then
							sudo mv "$ARG" "$ARG2"
							if [ $? -eq 0 ]; then
								sudo echo "Moved file $ARG to the $ARG2"
							else
								sudo echo "Error: Could not move file '$ARG'"
							fi
						fi
					fi
					if [ "$CMD" = "copy" ]; then
						if [ -n "$ARG2" ]; then
							sudo cp "$ARG" "$ARG2"
							if [ $? -eq 0 ]; then
								sudo echo "Copied file: $ARG to $ARG2"
							else
								sudo echo "Error: Could not copy file '$ARG' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "rename" ]; then
						if [ -n "$ARG2" ]; then
							sudo mv "$ARG" "$ARG2"
							if [ $? -eq 0 ]; then
								sudo echo "Renamed file: $ARG to $ARG2"
							else
								sudo echo "Error: Could not rename file '$ARG' to '$ARG2'"
							fi
						fi
					fi
					if [ "$CMD" = "display" ]; then
						if [ ! "$ARG" = "-directory" ]; then
							if [ ! "$ARG" = "-file" ]; then
								sudo echo "$ARG"
								if [ ! $? -eq 0 ]; then
									sudo echo "Error: Could not display text '$ARG'."
								fi
							fi
						fi
					fi
					if [ "$CMD" = "cycle" ]; then
						if [ "$ARG" = "forever" ]; then
							sed -n '/cycle \forever/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle_forever.cs
							while true
							do
								sudo controlscriptrun.sh -Rf /tmp/ckrnl_cycle_forever.cs
							done
						else
							sed -n '/cycle \$ARG/,/done/p' "$SCRIPT" > /tmp/ckrnl_cycle.cs
							for i in {1..$ARG}
							do
								sudo controlscriptrun.sh -Rf /tmp/ckrnl_cycle.cs
							done
						fi
					fi
					if [ -n "$ARG2" ]; then
						if [ "$CMD" = "display" ]; then
							if [ "$ARG" = "-file" ]; then
								if [ -f "$ARG2" ]; then
									sudo cat "$ARG2"
								else
									sudo echo "Error: '$ARG2' is not a file, or '$ARG2' not exist or file not readable."
								fi
							fi
							if [ "$ARG" = "-directory" ]; then
								if [ -d "$ARG2" ]; then
									sudo ls "$ARG2"
								else
									sudo echo "Error: '$ARG2' is not a directory, or '$ARG2' not exist or directory not readable."
								fi
							fi
						fi
						if [ "$CMD" = "write" ]; then
							if [ -f "$ARG2" ]; then
								sudo echo "$ARG" > "$ARG2"
								if [ $? -eq 0 ]; then
									sudo echo "Writed text '$ARG' to the: $ARG2"
								else
									sudo echo "Error: Could not write '$ARG' to file '$ARG2'"
								fi
							else
								sudo echo "Error: No such text file '$ARG2'."
							fi
						fi
						if [ "$CMD" = "#value" ]; then
							VALUE_NUM=$((VALUE_NUM + 1))
							if [ -n "$ARG3" ]; then
								declare "VALUE$VALUE_NUM"="$ARG3"
								echo "$VALUE$VALUE_NUM"
							else
								sudo echo "Syntax Error: Line '$LINE_NUM': No enough arguments, to set value, write: '#value COUNT 1"
							fi
						fi
						if [ -n "$ARG3" ]; then
							if [ -n "$ARG4" ]; then
								if [ "$CMD" = "if" ]; then
									if [ ! "$ARG3" = "!" ]; then
										if [ "$ARG4" = "=" ]; then
											if [ "$ARG2" = "ARG4" ]; then
												sudo sed -n '/if \[/,/ifend/p' "$SCRIPT" > /tmp/ckrnl_if.cs
												sudo controlscriptrun.sh -Rf /tmp/ckrnl_if.cs
											fi
										fi
									fi
								fi
							fi
							if [ "$CMD" = "calculate" ]; then
								if [ ! -n "$ARG4" ]; then
									CALCULATE="$ARG $ARG2 $ARG3"
									ANSWER="$(($CALCULATE))"
									echo "$ANSWER"
								fi
							fi
						fi
					fi
				fi
				break
			fi
		done
	done < "$SCRIPT"
	if [ -f /tmp/ckrnl_code.cs ]; then
		sudo rm /tmp/ckrnl_code.cs
	fi
	if [ -f /tmp/ckrnl_if.cs ]; then
		sudo rm /tmp/ckrnl_if.cs
	fi
	if [ -f /tmp/ckrnl_cycle.cs ]; then
		sudo rm /tmp/ckrnl_cycle.cs
	fi
	if [ -f /tmp/ckrnl_cycle_forever.cs ]; then
		sudo rm /tmp/ckrnl_cycle_forever.cs
	fi
fi