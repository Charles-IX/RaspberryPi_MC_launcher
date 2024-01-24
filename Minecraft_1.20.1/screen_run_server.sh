#!/bin/bash

lock_file="/home/charles/Minecraft/lock"

if [ -e "$lock_file" ]; then
    echo "Another instance of Minecraft server is running, located in"
    cat "$lock_file"
    exit 1
fi

cd /home/charles/Minecraft/Minecraft_1.20.1
echo "$(pwd)" > "$lock_file"
# cat "$lock_file"
screen -S minecraft -d -m /home/charles/Minecraft/Minecraft_1.20.1/run_server.sh -L -Logfile /home/charles/Minecraft/Minecraft_1.20.1/screen_log
echo "A screen instance is now running."
echo "Enter 'screen -r minecraft' in terminal to show server status, Then enter Ctrl+A and tap 'D' to escape."
echo "Debug: screen command exited with status: $?"
