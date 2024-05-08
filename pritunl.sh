#!/bin/bash

set -e
greentextcolor="\e[32m"
redtextcolor="\e[31m"
boldtext="\e[1m"
normaltext="\e[0m"
normaltextcolor="\e[0m"

# Initialize variables
connect=false
disconnect=false
profileId=""




# Function to echo colored text
echoColored() {
	color=$1
	bold=$2
	message=$3
	echo -e "${color}${bold}${message}${normaltextcolor}${normaltext}"
}

# Function to extract IP addresses from text
get_ip_addresses() {
		grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}"
}

show_connections() {
	echo ""
	# Command to list pritunl-client connections and apply color formatting
	pritunl-client list | sed -E \
		-e 's/(Active)/\o033[32m&\o033[0m/g' \
		-e 's/(Connecting)/\o033[31m&\o033[0m/g' \
		-e 's/([0-9]{1,3}\.){3}[0-9]{1,3}/\o033[32m&\o033[0m/g'
}

show_connections_highlight_selected() {
	echo ""
	# Command to list pritunl-client connections and apply color formatting
	pritunl-client list | sed -E \
		-e 's/('"$profileId"'|Active)/\o033[32m&\o033[0m/g' \
		-e 's/(Connecting)/\o033[31m&\o033[0m/g' \
		-e 's/([0-9]{1,3}\.){3}[0-9]{1,3}/\o033[32m&\o033[0m/g'
}


show_connections_3times() {
	for ((i = 1; i <= 3; i++)); do
		clear
		show_connections
		sleep 2
	done
}


show_connections_3times_highlight_selected() {
	for ((i = 1; i <= 3; i++)); do
		clear
		show_connections_highlight_selected
		sleep 2
	done
}

main() {
	clear

	# Show the status of all VPN connections
	show_connections

	# Ask the user if they want to connect or disconnect
	echo ""
	echoColored "${greentextcolor}${boldtext}Press [${redtextcolor}c${greentextcolor}] to connect or press [${redtextcolor}d${greentextcolor}] to disconnect."
	echo ""
	echoColored "${greentextcolor}${boldtext}      ...or ${redtextcolor}any${greentextcolor} other key to exit."

	# Read the user's input
	read -n 1 key

	# Abort if any other key is pressed
	if [[ $key != "c" && $key != "d" ]]; then
		echo ""
		echoColored $redtextcolor $boldtext "Goodbye!"
		echo ""
		exit 1
	fi

	# Set the connect and disconnect variables
	if [[ $key == "c" ]]; then
		connect=true
	fi

	if [[ $key == "d" ]]; then
		disconnect=true
	fi


	if [[ $disconnect == true ]]; then
		clear
		echoColored "Disconnecting..."
		# Disconnect from the VPN
		active_ids_first_chars=$(pritunl-client list | grep 'Active' | awk '{print substr($2, 1, 1)}')
		for char in $active_ids_first_chars; do
			profileId=""
			profileId=$(pritunl-client list | grep '| '$char | grep -e Active | awk '{print $2}')
			if [[ $profileId ]]; then
				echo ""
				echoColored $greentextcolor $boldtext "Disconnecting from $profileId"
				echo "pritunl-client stop $profileId"
				pritunl-client stop $profileId
				echo ""
				show_connections_highlight_selected
				sleep 2
			fi
		done

		show_connections
	fi

	if [[ $connect == true ]]; then
		clear
		show_connections
		echo ""
		echoColored "${greentextcolor}${boldtext}Choose which profile you wish to connect to:"
		echo ""
		inactive_ids_first_chars=$(pritunl-client list | grep 'Inactive' | awk '{print substr($2, 1, 1)}')
		IFS=$'\n'   # Set the Internal Field Separator to newline to handle multi-line input
		for char in $inactive_ids_first_chars; do
			profileId=$(pritunl-client list | grep -e '^| '$char | awk '{print $2}')
			remainingCharacters="${profileId:1}"
			echoColored "${greentextcolor}${boldtext}    Press [${redtextcolor}$char${greentextcolor}] to connect to profile ${redtextcolor}$char${greentextcolor}${remainingCharacters}."
		done
		echo ""
		echoColored "${greentextcolor}${boldtext}      ...or any other key to abort."
		read -n 1 profile

		echo ""

		profileId=$(pritunl-client list | grep -e '^| '$profile | awk '{print $2}')
		
		echo ""
		echoColored $greentextcolor $boldtext "Connecting to ${profileId}..."
		echo ""
		pritunl-client start $profileId -r

		show_connections_3times_highlight_selected
		

	fi

}

while true; do
	main
done
