#!/bin/bash

# Bring up a bridge network interface that connects the Open/Remote network
# to the WAN network interface specified.
bridgeup() {
	local BRIDGE=$1
	local WAN_IF=$2
	local OPEN_IF=$3

	echo "Golden Gate connecting bridging $OPEN_IF to Host network interface $WAN_IF"

	echo "  Kill dhclients and shutdown interfaces"
	killall -9 dhclient 2> /dev/null
	ifconfig $BRIDGE 0.0.0.0 down 2> /dev/null
	ifconfig $OPEN_IF 0.0.0.0 down 2> /dev/null
	ifconfig $WAN_IF 0.0.0.0 down 2> /dev/null
	brctl delbr $BRIDGE 2> /dev/null

	echo "  Create bridge"
	brctl addbr $BRIDGE 
	brctl addif $BRIDGE $WAN_IF 
	brctl addif $BRIDGE $OPEN_IF 

	echo "  Configure bridge"
	brctl stp $BRIDGE on

	echo "  Raise bridge"
	ifconfig $WAN_IF up
	ifconfig $OPEN_IF up
	ifconfig $BRIDGE up

	echo "  Get Bridge IP via DHCP"
	dhclient -i $BRIDGE -1 > /dev/null
}

ALL_INTERFACES=()
USB_INTERFACES=()
VIRTUAL_INTERFACES=()
UNKNOWN_INTERFACES=()
REGULAR_INTERFACES=()

# Get all connected network interfaces and sort into lists above
enumerate_interfaces() {
	echo "Enumerating Network Interfaces"
	for DEV in /sys/class/net/*; do
		LINK=`readlink $DEV`
		DEV=`basename $DEV`
		if echo $LINK | grep -q virtual; then 
			VIRTUAL_INTERFACES+=($DEV)
			echo "  Virtual interface $DEV"
		elif echo $LINK | grep -q usb; then
			USB_INTERFACES+=($DEV)
			echo "  USB interface $DEV"
		else 
			REGULAR_INTERFACES+=($DEV)
			echo "  Regular interface $DEV"
		fi
		ALL_INTERFACES+=($DEV)
	done
}

enumerate_interfaces

# We need one regular interface ( that should be the VM connection to host secure network ),
# and the USB interface.
if [ ${#REGULAR_INTERFACES[@]} -eq 0 ]; then
	echo "No regular interfaces found. Abort"
	exit 1
fi

if [ ${#REGULAR_INTERFACES[@]} -ne 1 ]; then
	echo "More than one regular interface found. Will assume ${REGULAR_INTERFACES[0]} is Host"
fi

if [ ${#USB_INTERFACES[@]} -eq 0 ]; then
	echo "No USB interfaces found. Abort"
	exit 1
fi

if [ ${#USB_INTERFACES[@]} -ne 1 ]; then
	echo "More than one USB interface found. Will assume ${USB_INTERFACES[0]} is Open Network"
fi

# Bring up bridge
bridgeup br0 ${REGULAR_INTERFACES[0]} ${USB_INTERFACES[0]}

echo "Bridge : `ifconfig br0 | grep inet | grep -v inet6`"

