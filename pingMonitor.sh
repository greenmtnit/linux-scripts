#!/bin/bash

# for fun

C=$(printf '\033')
RED="${C}[1;31m"
GREEN="${C}[1;32m"
BLUE="${C}[1;34m"
NC="${C}[0m"

#? print help
if [ "$1" == "-h" ]
then 
	echo "${GREEN}Here is the help....${NC}"
	echo "${BLUE}Example: ./pingMonitor.sh  -s 8.8.8.8 -m /home/me/mainlog.csv -f /home/me/faillog.csv${NC}"
	exit 1
fi

while getopts ':s:m:f:' option; do
  case "$option" in
    s) server=$OPTARG ;;
    m) mainlog=$OPTARG ;;
    f) faillog=$OPTARG ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       exit 1 ;;
    \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       exit 1 ;;
  esac
done

if [[ -z $server ]] || [[ -z $mainlog ]] || [[ -z $faillog ]]; then
    echo "${BLUE}Example: ./pingMonitor.sh -s 8.8.8.8 -m /home/me/mainlog.csv -f /home/me/faillog.csv${NC}" >&2
    exit 1
fi

#? Check if the server argument is a valid IP address.
# if ! [[ $server =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
# then
# 	echo "Error: Invalid server IP address: $server" >&2
# 	exit 1
# fi

#? Check if the main log file already exists.
if [ -e "$mainlog" ]
then
	read -p "Error: Main log file already exists. Overwrite? (y/n) " -n 1 -r
	echo
	if ! [[ $REPLY =~ ^[Yy]$ ]]
	then
		exit 1
	else
		rm $mainlog
	fi
fi

#? Check if the fail log file already exists.
if [ -e "$faillog" ]
then
	read -p "Error: Fail log file already exists. Overwrite? (y/n) " -n 1 -r
	echo
		if ! [[ $REPLY =~ ^[Yy]$ ]]
		then
			exit 1
		else 
			rm $faillog
	fi
fi
hostname=$(hostname)

# Pretend start time is successful ping to calculate seconds since successful response in case we never get a response.
lastSuccessful=$(date)

echo "Source, Destination, Date, Time, ResponseTime, Status" >> "$mainlog"
echo "Source, Destination, Date, Time, ResponseTime, Status" >> "$faillog"

while true
do
  # Use ping to test the connection to the server.
  # -c 1 specifies that we only want to send one packet.
  # -w 4 specifies a 4 second timeout.
  # add 1 second sleep to make it so it only pings once per second
  sleep 1
  pingResult=$(ping -c 1 -w 4 $server)
  #pingResult=$(ping -c 1 -i 0.001 -w 4 $server)

  # Check if the ping was successful.
  if [ $? -ne 0 ]
  then
	# If we get here, it means the ping failed or timed out.

	# Calculate the time since the last successful ping.
	timespan=$(($(date +%s) - $(date -d "$lastSuccessful" +%s)))

	# Display a message to the user.
	timenow=$(date +%H:%M.%S)
	echo "$timenow : Last Ping Timed out. Logged to file. $timespan Since last success"

	# Log the failure to the fail log file.
	date=$(date +%Y-%m-%d)
	time=$(date +%H:%M:%S)
	echo "$hostname, $server, $date, $time, 4001, Failed" >> $faillog

	# Pause for 1 second in case the network interface goes down.
	sleep 1
	else
		# If we get here, it means the ping was successful.

		# Update the time since the last successful ping.
		lastSuccessful=$(date)

		# Display the ping time to the user.
		timenow=$(date +%H:%M:%S)
		pingtime=$(echo "$pingResult" | grep time= | cut -d "=" -f 4 | cut -d " " -f 1)
		#echo $pingResult
		#pingTime=$(echo "$pingResult" | awk -F '/' 'END {print $5}')
		#echo $pingTime
		echo "$timenow : Ping Successful. Response Time = $pingtime"
		#echo $pingTime

		# Log the ping time to the main log file.
		date=$(date +%Y-%m-%d)
		time=$(date +%H:%M:%S)
		echo "$hostname, $server, $date, $time, $pingtime, Success" >> $mainlog
  fi
done
