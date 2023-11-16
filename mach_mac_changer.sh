#!/bin/bash

# Script Name: MACH (MAC Changer)
# Description: This script changes the MAC address of a specified network interface,
# restarts the interface, and checks network connectivity.

echo "  _   _   _   _ "
echo " / \ / \ / \ / \ "
echo "( M | A | C | H ) "
echo " \_/ \_/ \_/ \_/  "
echo ""

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if macchanger is installed
if ! command -v macchanger &> /dev/null; then
    error_msg "macchanger is not installed. Please install it using 'sudo apt-get install macchanger' and try again."
    exit 1
fi

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    error_msg "Please run the script as root or using sudo."
    exit 1
fi

# Functions to display colours
error_msg() {
    echo -e "${RED}Error: $1${NC}" >&2
}

success_msg() {
    echo -e "${GREEN}$1${NC}"
}

info_msg() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to change MAC address using macchanger
change_mac() {
    # Add spacing for better readability
    echo -e "\n"

    # Perform network scan and list available interfaces
    info_msg "Scanning for available network interfaces:"
    ifconfig -a | grep -E '^[a-zA-Z]' | cut -d ' ' -f 1

    # Prompt user to choose the interface
    read -p "Enter the interface to change MAC address: " user_interface

    # Add spacing for better readability
    echo -e "\n"

    # Validate user input
    if ! ifconfig $user_interface &> /dev/null; then
        error_msg "Invalid interface. Exiting..."
        exit 1
    fi

    # Change MAC address using macchanger
    sudo macchanger -r $user_interface

    success_msg "MAC address successfully changed for $user_interface"

    # Add spacing for better readability
    echo -e "\n"

    # Restart network interface
    info_msg "Restarting network interface..."
    sudo ifconfig $user_interface down
    sudo ifconfig $user_interface up

    # Add spacing for better readability
    echo -e "\n"

    # Sleep for a short duration to allow the network to stabilize
    sleep 2

    # Ping 8.8.8.8 to ensure network connection
    info_msg "Testing network connection..."
    if ping -c 3 8.8.8.8 &> /dev/null; then
        success_msg "Network connection is working again."
    else
        error_msg "Network is unreachable."
    fi
}

# Main function call to change MAC address
change_mac
