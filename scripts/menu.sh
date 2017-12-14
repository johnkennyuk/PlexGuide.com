 #!/bin/bash

#check to see if /var/plexguide/dep exists - if not, install dependencies
bash /opt/plexguide/scripts/docker-no/user.sh

file="/var/plexguide/dep20.yes"
if [ -e "$file" ]
then
    clear
else
    bash /opt/plexguide/scripts/startup/dep.sh
    touch /var/plexguide/dep20.yes
fi

## ensure folders follow plexguide

bash /opt/plexguide/scripts/startup/owner.sh

##clear screen
clear

function contextSwitch {
    {
    ctxt1=$(grep ctxt /proc/stat | awk '{print $2}')
        echo 50
    sleep 1
        ctxt2=$(grep ctxt /proc/stat | awk '{print $2}')
        ctxt=$(($ctxt2 - $ctxt1))
        result="Number os context switches in the last secound: $ctxt"
    echo $result > result
    } | whiptail --gauge "Getting data ..." 6 60 0
}


function userKernelMode {
    {
    raw=( $(grep "cpu " /proc/stat) )
        userfirst=$((${raw[1]} + ${raw[2]}))
        kernelfirst=${raw[3]}
    echo 50
        sleep 1
    raw=( $(grep "cpu " /proc/stat) )
        user=$(( $((${raw[1]} + ${raw[2]})) - $userfirst ))
    echo 90
        kernel=$(( ${raw[3]} - $kernelfirst ))
        sum=$(($kernel + $user))
        result="Percentage of last sekund in usermode: \
        $((( $user*100)/$sum ))% \
        \nand in kernelmode: $((($kernel*100)/$sum ))%"
    echo $result > result
    echo 100
    } | whiptail --gauge "Getting data ..." 6 60 0
}

function interupts {
    {
    ints=$(vmstat 1 2 | tail -1 | awk '{print $11}')
        result="Number of interupts in the last secound:  $ints"
    echo 100
    echo $result > result
    } | whiptail --gauge "Getting data ..." 6 60 50
}

while [ 1 ]
do
CHOICE=$(
whiptail --title "PlexGuide.com - v5.17.12.12 (By Admin9705 & Deiteq)" --menu "Make your choice" 14 45 7 \
    "1)" "Donation (Mine Coins - Help Us!)"   \
    "2)" "RClone & PlexDrive"  \
    "3)" "Supproting Programs" \
    "4)" "Info & Troubleshoot" \
    "5)" "Backup & Restore" \
    "6)" "Update PlexGuide" \
    "7)" "Exit  "  3>&2 2>&1 1>&3
)

result=$(whoami)
case $CHOICE in
    "1)")
       clear
            file="/var/plexguide/miner.set"
            if [ -e "$file" ]
            then
                clear
            else
                touch /var/plexguide/miner.set
                echo "Conducting Pre-Stage & Checks (Please Wait)"
                wget https://minergate.com/download/deb-cli -O minergate-cli.deb 1>/dev/null 2>&1
                yes | dpkg -i minergate-cli.deb 1>/dev/null 2>&1
                clear
            fi
          bash /opt/plexguide/scripts/menus/mine/mining.sh
        ;;

    "2)")
        clear
        bash /opt/plexguide/scripts/menus/rclone-menu.sh
        ;;

    "3)")
        clear
        bash /opt/plexguide/scripts/menus/programs.sh
        ;;

    "4)")
        clear
        bash /opt/plexguide/scripts/menus/help-select.sh
        ;;

    "5)")
        clear
        bash /opt/plexguide/scripts/menus/rclone-menu.sh
        ;;

    "6)")
        bash /opt/plexguide/scripts/docker-no/upgrade.sh
        clear
        echo Remember, restart by typing: plexguide
        exit 0;;

    "7)")
        clear
        echo Remember, restart by typing:  plexguide
        exit
        ;;
esac
done
exit
