#!bin/bash

# Author:   Franklin Reyes
# Purpose:  Runs RetroSync.sh for first time setup. Also promtps user if they'd like to setupa cron job

#==========================================Functions================================================
# Function prompting user to enter RetroPie's IP
enterIP () {
    echo "Please enter your RetroPie's IP"
    read PiIP
    echo ""
    echo "The IP you have selected is \""$PiIP"\""
    echo "Is this correct? <y/n/cancel>"
    read response
}

# Function to setup cronjob (Optional. If user does not wish to setup cron job, then it will only
# sync the current data between games)
setupCrontab () {

    # While loop prompting user if they want to set it up or not
    while [[ true ]]; do
        echo ""
        echo "Would you like to setup a cron job? <y/n>"
        read cronResponse

        if [[ $cronResponse == "y" ]]; then # If user chooses to create cron job
            echo ""
            echo "Every how many minutes would you like to set it for? (Minutes) <1-59>"
            read minutes
            while [[ $minutes -lt "1" || $minutes -gt "59" ]]; do # while entry is less than 1 minute or bigger than 59 minutes, it will keep prompting user to enter a correct entry
                echo ""
                echo "You selected: "$minutes" minutes"
                echo "Invalid entry. Please select a value between 1 and 59 (Minutes) <1-59>"
                read minutes
            done
            (crontab -l ; echo "*/$minutes * * * * $PWD/RestroSync.sh $PiIP")| crontab - # Once user enters correct entry, it will append the cron job to the crontab
            break
        elif [[ $cronResponse == "n" ]]; then # If user does not choose to create cron job
            break
        else # User chose and invalid entry
            echo ""
            echo "Invalid entry."
            echo ""
        fi
    done
}
#=======================================End of Functions============================================

clear # Clears screen
enterIP # Prompts user for RetroPie's IP

# while loop verifying if user is entering correct IP
while [[ true ]]; do
    if [[ $response == "y" ]]; then # if user entered correct IP
        echo ""
        ./RetroSync.sh $PiIP # Runs shell script RetroSync.sh
        break
    elif [[ $response == "n" ]]; then # If user entered incorrect IP
        echo ""
        enterIP # Prompts user to enter IP Again
    elif [[ $response == "cancel" ]]; then
        exit
    else # User entered incorrect entry
        echo ""
        echo "Invalid entry."
        echo ""
        echo "The IP you have selected is \""$PiIP"\""
        echo "Is this correct? <y/n/cancel>"
        read response
    fi
done

# Prompts user if they'd like to setup a cron job (Optional)
setupCrontab
