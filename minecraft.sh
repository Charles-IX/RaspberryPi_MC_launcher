#!/bin/bash

lock_file=/home/charles/Minecraft/lock
ver=0.15
remote_url="Input your own MC url here"
trap 'echo "" && echo "" && exit 0' SIGINT

echo ""
echo "Minecraft server launcher v$ver by Charles"
date
echo "==========================================="


if [ -e "$lock_file" ]; then
    echo "A Minecraft server instance seems already running, located in"
    cat "$lock_file"
    echo "Connect $remote_url remotely to join the game."
    service="$(cat $(cat $lock_file)/service)"
    status=$(systemctl show -p ActiveState --value $service)
    screen_log="$(cat $lock_file)/screen_log"

    if [ "$status" != "active" ]; then
	echo "However, $service has run into '$status' state."
	echo "You can check systemctl for details, or simply remove the lock file to perform manual restart."
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

else
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
