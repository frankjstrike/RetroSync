#!/bin/bash

# Author:   Franklin Reyes
# Purpose:  -Syncs save data between RetroPie and PC's RetroArch. Useful for
#           setting up a crontab to continuosly keep save data constantly synced

#************************************************************************************************************
# Something to keep in mind before using:
# - Enter your Pi's IP address in line 15 (Recommend using a static IP!)
# - Remove any special characters from game file's name when saving
# any game files to either RetroPie or RetroArchfile directory. (Tryin to figure out a way around this T.T)
#************************************************************************************************************

# Your Pi's IP
PiIP="$1"

#Connection profile for your pi
Connection="pi@$PiIP"

# Paths
RomsPath="./RetroPie/roms" # Path where all consoles are in RetroPie
RArchSavesPath=~/.config/retroarch/saves # Path where all saves files are in Retroarch defeault config

# Lists
RemoteDirectoryList="$(ssh $Connection "ls -d $RomsPath/*")" # List of
SrmFilesRemoteList="$(ssh $Connection find ./ -name '*.srm')" # List of Save Lifes in RetroPie

# For each loop testing each .srm file on RetroPi to see if its newer or
# older the corresponding file in your PC's RetroArch 'saves' Folder and then
# overwrites the older one with the new one
for Save in $SrmFilesRemoteList; do

    Game=$(basename $Save) # Extracts just the game's name

    # Last change value for RetroPie and RetroArch files
    RemoteSaveFile=$(ssh $Connection "stat -c %Y $Save") # RetroPie Files
    LocalSaveFile=$(stat -c %Y $RArchSavesPath/$Game) # RetroArch Files

    if [[ $RemoteSaveFile -gt $LocalSaveFile ]]; then # Checks if the RetroPie file is greater than RetroArch file
        scp $Connection:$Save $RArchSavesPath/$Game # Copies RetroPie files to RetroArch
    elif [[ $LocalSaveFile -gt $RemoteSaveFile ]]; then # Checks if the RetroArch file is greater than RetroPie file
        scp $RArchSavesPath/$Game $Connection:$Save # Copies RetroArch files to RetroPie
    elif [[ $LocalSaveFile -eq $RemoteSaveFile ]]; then # Checks if RetroArch and RetroPie file are the same
        : # Do nothing
    fi

done 2> /dev/null # Suppreses errors
