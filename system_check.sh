#!/bin/bash
 
check_reboot() {
    if [ -f /var/run/reboot-required ]; then
        echo "Reboot is required."
    else
        echo "No reboot is required."
    fi
}
           
check_disk_full() {
    threshold=90 # Set the threshold percentage for disk usage
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$disk_usage" -ge "$threshold" ]; then
        echo "Disk usage is above $threshold%: $disk_usage% used."
    else
        echo "Disk usage is normal: $disk_usage% used."
    fi
}
           
check_root_full() {
    threshold=90 # Set the threshold percentage for root partition usage
    root_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$root_usage" -ge "$threshold" ]; then
        echo "Root partition usage is above $threshold%: $root_usage% used."
    else
        echo "Root partition usage is normal: $root_usage% used."
    fi
}
           
check_no_network() {
    if ! ping -c 1 google.com &> /dev/null; then
        echo "No network connection."
    else
        echo "Network connection is available."
    fi
}
           
# Perform health checks
check_reboot
check_disk_full
check_root_full
check_no_network
        

