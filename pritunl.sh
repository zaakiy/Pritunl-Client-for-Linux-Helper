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



user_prompt() {
	clear
	show_connections_highlight_selected
	# Ask the user if they want to connect or disconnect
	echo ""
	echoColored "${greentextcolor}${boldtext}Press [${redtextcolor}c${greentextcolor}] to connect or press [${redtextcolor}d${greentextcolor}] to disconnect."
	echo ""
	echoColored "${greentextcolor}${boldtext}      ...or ${redtextcolor}any${greentextcolor} other key to exit."
}

key=""
selectedKey=""
display_prompt_and_read_input() {
	user_prompt
  while true; do

    read -n 1 -t 2 -s key || true
    if [ -z "$key" ]; then
			user_prompt
      continue
    else
			selectedKey=$key
      break
    fi
  done
}

get_active_connections() {
	pritunl-client list | grep 'Active' | awk '{print substr($2, 1, 1)}'
}

disconnect() {
	# echo "debug running disconnect for $active_ids_first_chars" && sleep 2
	clear
	echoColored "Disconnecting..."
	# Disconnect from the VPN
	active_ids_first_chars=$(get_active_connections)
	for char in $active_ids_first_chars; do
		profileId=""
		profileId=$(pritunl-client list | grep '| '$char | grep -e Active | awk '{print $2}')
		# echo "debug $profileId needs to be disconnected" && sleep 2
		if [[ -n $profileId ]]; then
			echo ""
			echoColored $greentextcolor $boldtext "Disconnecting from $profileId"
			echo "pritunl-client stop $profileId"
			pritunl-client stop $profileId
			echo ""
			show_connections_highlight_selected
			# echo debug 3 $profileId
			sleep 2
		fi
		sleep 2
	done

}

connect() {
	# echo "debug running connect" && sleep 2
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
	echoColored "${greentextcolor}${boldtext}      ...or any other key to go to the main menu."
	read -n 1 profile

	echo ""

	profileId=$(pritunl-client list | grep -e '^| '$profile | awk '{print $2}')
	profileIdToConnect="${profileId}" # This is because the profileId variable was being modified to be the most recently disconnected profileId
	if [[ -n $profileId ]]; then

		disconnect
		echo ""
		echoColored $greentextcolor $boldtext "Connecting to ${profileIdToConnect}..."
		echo ""
		pritunl-client start $profileIdToConnect -r
		profileId=${profileIdToConnect}
	fi

}

main() {
	key=""
	selectedKey=""
	profileId=""

	clear

	# Show the status of all VPN connections
	show_connections


	# Read the user's input
	display_prompt_and_read_input


	# Abort if any other key is pressed
	if [[ $selectedKey != "c" && $selectedKey != "d" ]]; then
		echo ""
		echoColored $redtextcolor $boldtext "Goodbye!"
		echo ""
		exit 1
	fi

	# Set the connect and disconnect variables
	if [[ $selectedKey == "c" ]]; then
		connect=true
	else
		# Important to reset the value for the next loop of main()
		connect=false
	fi

	if [[ $selectedKey == "d" ]]; then
		disconnect=true
	else
		# Important to reset the value for the next loop of main()
		disconnect=false
	fi


	if [[ $disconnect == true ]]; then
		active_ids_first_chars="" #important to reset because main will loop again

		# echo "debug disconnect is true" && sleep 2
		active_ids_first_chars=$(get_active_connections)
		if [ -z $active_ids_first_chars ]; then
			clear
			show_connections
			echo ""
			echoColored "${redtextcolor}There are already no Active connections."
			sleep 2
			break
		else
			disconnect
		fi
	fi

	if [[ $connect == true ]]; then
		# echo "debug connect is true" && sleep 2
		connect
	fi

}

while true; do
	main
done
