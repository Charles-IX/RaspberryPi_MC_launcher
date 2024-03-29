#!/bin/bash

ver=0.20.2
config_file=/home/$USER/.minecraft/raspi_mc_launcher_conf.sh

trap 'echo "" && echo "" && exit 0' SIGINT

echo ""
echo "Minecraft server launcher v$ver by Charles"
date
echo "==========================================="


# Detect whether is running by root, if so, exit with code 1.
if (( EUID == 0 )); then
    echo "The script must not be run as root."
    echo ""
    exit 1
fi


# Handle parameters.
if (( $# > 1 )); then
    echo "0 or 1 parameters expected, got $#."
else
    case $1 in
        "-h"|"--help")
            echo "This is a simple Bash script aiming to simplify the control the start/stop of several Minecraft Java Edition servers."
            if [ -e "$config_file" ]; then
                source $config_file
                echo "Config file: /home/$USER/.minecraft/raspi_mc_launcher_conf.sh"
                echo "Current Minecraft folder: $path"
            else
                echo "Config file does not exist. Is this the first time you run the script?"
                echo "If so, run with no parameter to create a new config."
            fi
            echo "For more information, please visit https://github.com/Charles-IX/RaspberryPi_MC_launcher ."
            echo ""
            echo "Available parameters:"
            echo "-h --help :  Print this help information."
            echo "-u --update :  Try to update minecraft.sh in your Minecraft folder using wget."
            echo ""
            exit 0
            ;;
        "-u"|"--update")
            echo "Trying to fetch latest minecraft.sh from GitHub, and will replace the current one in your Minecraft folder."
            echo ""
            if [ -e "$config_file" ]; then
                source $config_file
                wget -O $path/minecraft.sh https://raw.githubusercontent.com/Charles-IX/RaspberryPi_MC_launcher/main/minecraft.sh
                echo ""
                echo "Run the launcher again by typing 'mc' in the terminal."
                echo "If you are not running the latest version, you will be prompted to upgrade /usr/local/bin/mc ."
                echo ""
                exit 0
            else
                echo "Config file does not exist, don't know where to put minecraft.sh ."
                echo ""
                # echo "Is this the first time you run the script? If so, run with no parameter to create a new config."
            fi
            ;;
        "")
            ;;
        *)
            echo "Unexpected parameter. Run 'mc -h' or 'mc --help' for help."
            echo ""
            exit 2
            ;;
    esac
fi



# Try to read config file, will prompt to create one if does not exist.
if [ -e "$config_file" ]; then
    source $config_file
else
    echo "Hello there,"
    echo "it seems that you are running the launcher for the first time."
    echo "In order to function normally, the launcher will attempt to write a config file located in ~/.minecraft/raspi_mc_launcher_conf.sh ."
    echo ""
    if [ ! -e "/home/$USER/.minecraft" ]; then
        mkdir /home/$USER/.minecraft
    elif [ ! -d "/home/$USER/.minecraft" ]; then
        echo "Unexpected incident: You have a .minecraft file in /home/$USER and it's not a directory."
        echo "Can't write config file."
        echo ""
        exit 114
    fi

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
    echo ""
    echo "Then you can paste your remote url here so the launcher can remind you when the server has launched like this: 'Connect <your url> remotely to join the game.'"
    echo "...Or you can simply press Enter to skip this."
    read -r url
    if [ $url != "" ]; then
        echo "Url successfully set to $url ."
    else
        echo "Url input skipped."
    fi

    echo -e "path=$path\nlock_file=$path/lock\nremote_url=$url\n" > $config_file
    echo ""
    echo "You can always start over by deleting $config_file ."
    echo "Now the launcher will attempt to copy itself to /usr/local/bin/mc so next time you can just type 'mc' to run the launcher."
    echo ""
    sudo cp -v $0 /usr/local/bin/mc
    echo ""
    source $config_file
    if [ ! -e "$path/server.sh" ]; then
        echo "Then let's set up the server list."
        echo "A server.sh is needed in your Minecraft folder. Here is an example:"
        echo ""
        wget -O - https://raw.githubusercontent.com/Charles-IX/RaspberryPi_MC_launcher/main/server.sh | cat
        echo ""
        echo "Do you wish to create one in your Minecraft folder?"
        while true; do
            echo "Yes, No?"
            read -p "[ Y / N ]: " servers
            case $servers in
                Y|y)
                    wget -O $path/server.sh https://raw.githubusercontent.com/Charles-IX/RaspberryPi_MC_launcher/main/server.sh
                    echo ""
                    break
                    ;;
                N|n)
                    echo "You will be prompted to create one later."
                    break
                    ;;
                *)
                    echo "Invalid option. Try again."
                    ;;
            esac
        done
    fi
fi


# Notify the user if there is newer version in Minecraft folder.
ver_2=$(grep "ver=" $path/minecraft.sh | awk -F "ver=" '{print $2}' | head -n1)
if [ "$ver_2" != "" ]; then
    if [ "$(printf '%s\n' "$ver_2" "$ver" | sort -V | head -n1)" = "$ver" ]; then
        if [ "$ver_2" != "$ver" ]; then
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
                        echo ""
                        sudo cp -v $path/minecraft.sh /usr/local/bin/mc
                        echo ""
                        echo "Run the launcher again to use the newer version."
                        echo ""
                        exit 0
                        ;;
                    N|n)
                        echo "Upgrade skipped."
                        echo ""
                        break
                        ;;
                    *)
                        echo "Invalid option. Try again."
                esac
            done
        fi
    fi
fi


if [ ! -e "$path/server.sh" ]; then
    echo "Server list does not exist."
    echo "A server.sh is needed in your Minecraft folder. Here is an example:"
    echo ""
    wget -O - https://raw.githubusercontent.com/Charles-IX/RaspberryPi_MC_launcher/main/server.sh | cat
    echo ""
    echo "Do you wish to create one in your Minecraft folder?"
    while true; do
        echo "Yes, No?"
        read -p "[ Y / N ]: " servers
        case $servers in
            Y|y)
                wget -O $path/server.sh https://raw.githubusercontent.com/Charles-IX/RaspberryPi_MC_launcher/main/server.sh
                echo ""
                break
                ;;
            N|n)
                echo "Can't tell which servers are available without a proper server.sh ."
                echo ""
                exit 3
                break
                ;;
            *)
                echo "Invalid option. Try again."
                ;;
        esac
    done
fi


# If there is a running server instance, do not run a new one.
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
                    sudo -u $USER screen -r minecraft
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
	            sudo -u $USER screen -r minecraft
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
    source $path/server.sh
    echo "Enter a number between 1 and 2 or Q to quit."

    while true; do
        read -p "[ 1 / 2 / Q ]: " choice

        case $choice in
            1)
                echo "Running $name_1"
       	        systemctl start $service_1
	            systemctl status $service_1 --no-pager
	            break
	            ;;
            2)
	            echo "Running $name_2"
	            systemctl start $service_2
	            systemctl status $service_2 --no-pager
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
