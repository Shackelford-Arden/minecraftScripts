#!/bin/bash

# This script is for personal use to create a render of a minecraft server.
# Due to limitation of memory on the VPS with AWS, run this script during times where no one is on the server.
# The amount of memory needed for the render kills the MineCraft server.

echo "Starting Render..."

# Like a smart person, we make a backup first.
echo "Creating a backup of the data"
echo "This is the data that we will use for the render just in case something goes wrong"

/home/ubuntu/minecraft/backupMinecraftServer.sh

# Begin render process.

# Create a date variable to make sure that we create a render using the most recent data.

latestFile="$(ls -t /home/ubuntu/minecraftBackups | head -n1)"
echo "Moving to the backups folder"
tmux send -t minecraftServer 'cd /home/ubuntu/minecraftBackups' ENTER

echo "Delete the previous render's extract"
tmux send -t minecraftServer 'rm -rf ./home' ENTER

echo "Uncompress the backup we made a moment ago"
tmux send -t minecraftServer 'tar -xf '$latestFile ENTER

echo "Move into the correct directory to begin the render"
tmux send -t minecraftServer 'cd ./home/ubuntu/minecraft/' ENTER

echo "Begin the render process!"
tmux send -t minecraftServer 'overviewer.py --rendermodes=smooth-lighting ./MCMadness /home/ubuntu/mcOverview' ENTER

echo "Now we'll wait 25 minutes for the render to complete"

sleep 25m

echo "Render complete! Now copying files to web server"
tmux send -t minecraftServer 'cp -R /home/ubuntu/mcOverview/* /var/www/minecraft' ENTER
tmux send -t minecraftServer 'cp /var/www/index.html.bak /var/www/minecraft index.html' ENTER

echo "Cleaning the mcOverview directory for future use..."
tmux send -t minecraftServer 'rm -rf /home/ubuntu/mcOverview/*' ENTER

echo "Render process complete! Go to http://minecraft.ardenshackelford.com to view it!"