# Minecraft Scripts

These scripts are the beginning of the creation of a control panel.

# Design

## FrontEnd
change dirctory into `./controlPanel/node_server/`
run `node server.js`
navigate to `IP-ADDRESS-OF-SERVER:8080` in a web browser.

# Backend
Node.js implemented to start and stop the server.

## Usage
### Install Control Panel
Run the `installControlPanel.sh` script, it will install node, npm, and download the correct node packages
### Install Minecraft w/ Forge
The `installmcForge.sh` script will find the latest version of Vanilla Minecraft Server and Forge server and install them. It will also install any needed dependencies such as Java and Tmux.
use command line args if you want something specific.


