#!/bin/bash

ver=0.16.4
config_file=/home/$USER/.minecraft/raspi_mc_launcher_conf.sh

trap 'echo "" && echo "" && exit 0' SIGINT

echo ""
echo "Minecraft server launcher v$ver by Charles"
date
echo "==========================================="

if (( EUID == 0)); then
    echo "The script must not be run as root."
    exit 1
fi

if [ -e "$config_file" ]; then
    source $config_file
else
    echo "Hello there,"
    echo "it seems that you are running the launcher for the first time."
    echo ""
    echo "In order to function normally, the launcher will attempt to write a config file located in ~/.minecraft/raspi_mc_launcher_conf.sh"
    echo "Enter your path to the Minecraft directory, or type 'yes' (with no quote) to use the default ~/Minecraft ."
    while true; do
        IFS= read -r path
        if [ "$path" == "yes" ]; then
            path=/home/$USER/Minecraft
            echo "Path successfully set to $path ."
            break
        elif [ -e "$path" ]; then
            if [ -d "$path" ]; then
                echo "Path successfully set to $path ."
                break
            fi
        fi
        echo "You should enter a path to the Minecraft directory, not a file, and do not add quotation marks."
        echo "You can also just type 'yes' to use /home/$USER/Minecraft ."
    done
    echo "Then you can paste your remote url here so the launcher can remind you when the server has launched like this: 'Connect <your url> remotely to join the game.'"
    echo "...Or you can simply press Enter to skip this."
    read -r url
    if [ $url != "" ]; then
        echo "Url successfully set to $url ."
    else
        echo "Url input skipped."
    fi
    touch $config_file
    echo -e "path=$path\nlock_file=$path/lock\nremote_url=$url\n" > $config_file
    echo "You can always start over by deleting $config_file ."
    echo "Now the launcher will attempt to copy itself to /usr/local/bin/mc so next time you can just type 'mc' to run the launcher."
    sudo cp -v $0 /usr/local/bin/mc
    echo ""
    source $config_file
fi

ver_2=$(grep "ver=" $path/minecraft.sh | awk -F "ver=" '{print $2}')
if [ "$ver_2" != "" ]; then
    if (( ver_2 > ver )); then
        echo "A newer version of Minecraft server launcher detected in $path/minecraft.sh ."
        echo "Current version: $ver"
        echo "New version: $ver_2"
        echo "Upgrade /usr/local/bin/mc now?"
        while true; do
            echo "Yes, No?"
            read -p "[ Y / N ]: " upgrade
            case $upgrade in
                Y|y)
                    echo "Will attempt to upgrade /usr/local/bin/mc ."
                    sudo cp -v $path/minecraft.sh /usr/local/bin/mc
                    echo "Run the launcher again to use the newer version."
                    exit 0
                    ;;
                N|n)
                    echo "Upgrade skipped."
                    break
                    ;;
            esac
        done
    echo ""
    fi
fi

if [ -e "$lock_file" ]; then
    echo "A Minecraft server instance seems already running, located in"
    cat "$lock_file"
    if [ "$url" != "" ]; then
        echo "Connect $remote_url remotely to join the game."
    fi
    service="$(cat $(cat $lock_file)/service)"
    status=$(systemctl show -p ActiveState --value $service)
    screen_log="$(cat $lock_file)/screen_log"

    if [ "$status" != "active" ]; then
	    echo "However, $service has run into '$status' state."
	    echo "You can check systemctl for details, or simply remove the lock file to enable a manual restart."
	    echo "You can also try to access to the Minecraft server console, but chances are the server is down."
        echo "Latest screen session is recorded in '$screen_log'." 
	    while true; do
            echo "Service status, Remove lock, show Console, show Log, Quit?"
            read -p "[ S / R / C / L / Q ]: " op

            case $op in
                S|s)
                    systemctl status $service
                    #break
                    ;;
                R|r)
                    rm $lock_file
                    echo "Lock file removed. Run launcher again to manually restart the server."
                    break
                    ;;
                C|c)
                    echo "Enter Ctrl+A then 'D' to return to terminal."
                    sleep 3
                    sudo -u charles screen -r minecraft
                    #break
                    ;;
                L|l)
                    less $screen_log
                    ;;
                Q|q)
                    break
                    ;;
                *)
                    echo "Invalid option. Try again."
            esac
        done

    else
        while true; do
            echo "Service status, sTop server, show Console, Quit?"
            read -p "[ S / T / C / Q ]: " op

            case $op in
	        S|s)
	            systemctl status $service
	            #break
	            ;;
	        T|t)
	            systemctl stop $service
		    systemctl status $service --no-pager
	            break
	            ;;
	        C|c)
	            echo "Enter Ctrl+A then 'D' to return to terminal."
	            sleep 3
	            sudo -u charles screen -r minecraft
	            #break
	            ;;
	        Q|q)
		    break
	            ;;
	        *)
	            echo "Invalid option. Try again."
	    esac
        done
    fi

else    # In this section you can manually add your servers.
    echo "Please select one server to run."
    echo "1. Minecraft 1.20.1 Forge"
    echo "2. Minecraft 1.20.4 Vanilla"
    echo "Enter a number between 1 and 2 or Q to quit."

    while true; do
        read -p "[ 1 / 2 / Q ]: " choice

        case $choice in
            1)
                echo "Running Minecraft 1.20.1 Forge"
       	        systemctl start minecraft_1.20.1
	            systemctl status minecraft_1.20.1 --no-pager
	            break
	            ;;
            2)
	            echo "Running Minecraft 1.20.4 Vanilla"
	            systemctl start minecraft_1.20.4
	            systemctl status minecraft_1.20.4 --no-pager
	            break
	            ;;
	        Q|q)
	            break
	            ;;
            *)
	            echo "Invalid option. Try again."
        esac
    done
fi

echo ""
