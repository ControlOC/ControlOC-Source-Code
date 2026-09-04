display "=== ControlOC Installer ==="
display "Select installation mode:"
display "Full-install (on whole disk) (1)"
display "ISO-Storage mode (ISO on a first disk and data on second disk) (2)"
linux
while true; do
	echo -n "What would you choose? (1/2)"
	read ANSWER
	if [ "$ANSWER" -qe 1 ]; then
		controlscript --runcode 
linux
