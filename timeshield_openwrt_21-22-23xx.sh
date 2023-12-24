# Timeshield script for OpenWRT v. 21.xx, 22.xx, 23.xx (not tested for 18.xx and 19.xx)

# This is free software, licensed under the GNU General Public License v2.
# See LICENSE for more information.
#
# Author: Kristiyan Georgiev <brave@brave-design.org>

#!/bin/sh
# 0 * * * * sh /path/to/your_script.sh - run script every hour
# */3 * * * * sh /path/to/your/script.sh - run every 3 minutes

# Current datastamp
CURRENT_DATASTAMP=$(date +"%F / %H:%M")

# Current full time
CURRENT_FULLTIME=$(date +"%H:%M")

# Get current time
CURRENT_HOUR=$(date +"%H")

# WAN interface
WAN_INTERFACE="wan" # Type interface by name 

# Hours to block WAN interface
BLOCK_HOURS="02 08 10 14 22"  # For example - block in 02, 08, 10, 14 and 22 hours

# Log file path
log_file="/opt/timeshield.log"

# Log file max size in kB
max_size_kb=25

clear
echo "▌║█║▌│║▌│║▌║▌█║ ★ T I M E S H I E L D ★ ▌│║▌║▌│║║▌█║▌║█"
echo "        for OpenWrt versions 21.x, 22.x, 23.x "
echo ""
echo "                 $CURRENT_DATASTAMP"
echo ""

# Logging
exec >> "$log_file" 2>&1
echo "Timeshield started at $CURRENT_FULLTIME"
echo "----------------------------------"

# Check time is equal with blocked hours
if echo "$BLOCK_HOURS" | grep -wq "$CURRENT_HOUR"; then
    echo "WAN TRAFFIC STOP"
    echo "Current time is: $CURRENT_FULLTIME"
    echo "Interface: $WAN_INTERFACE is OFF"
    ubus call network.interface.$WAN_INTERFACE down
else
    echo "WLAN TRAFFIC START"
    echo "Current time is: $CURRENT_FULLTIME"
    echo "Interface: $WAN_INTERFACE is ON"
    ubus call network.interface.$WAN_INTERFACE up
    
fi

echo "Timeshield finished at $CURRENT_FULLTIME"
echo ""

# Get the size of the log file in kilobytes
log_size_kb=$(du -k "$log_file" | cut -f1)

echo "Current log size: $log_size_kb kB"

# Check if the log size exceeds the maximum size
if [ "$log_size_kb" -gt "$max_size_kb" ]; then
    echo "Log file exceeds $max_size_kb kB. Deleting the log file."

# Delete the log file
    rm "$log_file"
    
    echo "Log file deleted."
else
    echo "Log file size is within the limit."
fi
echo "-----------------------------------"
echo ""
echo ""


