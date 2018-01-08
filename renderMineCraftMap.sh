#!/bin/bash

# Due to limitation of memory on the VPS with AWS, run this script during times where no one is on the server.
# The amount of memory needed for the render kills the MineCraft server.

# Begin render process.

# Create a date variable to make sure that we create a render using the most recent data.

latestFile="$(ls -t /home/ubuntu/minecraftBackups | head -n1)"

echo "Moving to the backups folder"
tmux send -t minecraftServer 'cd /home/ubuntu/minecraftBackups' ENTER

echo "Delete the previous render's extract"
tmux send -t minecraftServer 'rm -rf /home/ubuntu/minecraftBackups/home' ENTER

echo "Uncompress the backup we made a moment ago"
tmux send -t minecraftServer 'tar -xf '$latestFile ENTER

echo "Move into the correct directory to begin the render"
tmux send -t minecraftServer 'cd /home/ubuntu/minecraftBackups/home/ubuntu/minecraft/' ENTER

echo "Begin the render process!"
tmux send -t minecraftServer 'overviewer.py --rendermodes=smooth-lighting ./MCMadness /var/www/minecraft' ENTER

#echo "Render complete! Now copying files to web server"
#tmux send -t minecraftServer 'cp -R /home/ubuntu/mcOverview/* /var/www/minecraft/' ENTER

echo "Remove the index.html created by the render"
tmux send -t minecraftServer 'rm /var/www/minecraft/index.html' ENTER

echo "Replace index.html with the authenticatation index.html"
tmux send -t minecraftServer 'cp /home/ubuntu/minecraft/index.html.bak /var/www/minecraft/index.html' ENTER

echo "Make sure the .htaccess file is present to ensure better security"
tmux send -t minecraftServer 'cp /home/ubuntu/minecraft/.htaccess /var/www/minecraft/.htaccess' ENTER

# echo "Cleaning the mcOverview directory for future use..."
# tmux send -t minecraftServer 'rm -rf /home/ubuntu/mcOverview/*' ENTER

echo "Cleaning up uncompressed backup..."
tmux send -t minecraftServer 'rm -rf /home/ubuntu/minecraftBackups/home' ENTER
tmux send -t minecraftServer 'cd ~/' ENTER
echo "Render Complete!"
