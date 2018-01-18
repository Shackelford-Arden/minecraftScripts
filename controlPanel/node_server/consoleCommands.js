/**************************************************************
*  Minecraft Server Console Command Functions
*  Author(s): Weston Clark
*
*  Description:
*  This is a collection of exported functions that will be
*  used to stop/start the Minecraft server, run backups of the
*  server, and re-gen the dynmap.
*
*  File: consoleCommands.js
**************************************************************
*  Change Date      Name            Description
*  =============    ===========     ==========================
*  08/05/17         Weston Clark    Initial Creation
*
**************************************************************/

module.exports = {

  cp : require('child_process'),
  installVanillaServer: function(){
    //stop the MC server
    require('child_process').exec("../../minecraftCommands.sh installVanilla")
  },
  installForgeServer: function(){
    //stop the MC server
    require('child_process').exec("../../minecraftCommands.sh installForge")
  },
  uninstallServer: function(){
    //stop the MC server
    require('child_process').exec("../../minecraftCommands.sh uninstall")
  },
  stopServer: function(){
    //stop the MC server
    require('child_process').exec("../../minecraftCommands.sh stopServer")
  },
  startServer: function(ServerLocation){
    //start the MC server
    console.log("starting Server")
    // require('child_process').exec("../../minecraftCommands.sh startServer")
    var minecraftServerProcess = this.cp.spawn('java', [
      '-Xmx512M',
      '-Xms256M',
      '-jar',
      ServerLocation,
      'nogui'
    ]);
    console.log("started Server")
    return minecraftServerProcess;
  },
  
  runBackup: function(){
    //run a backup of the server files
    require('child_process').exec("../../minecraftCommands.sh backupServer")
  },
  
  renderMap: function(){
    //render the dynmap and update files accordingly
    require('child_process').exec("../../renderMineCraftMap.sh")
  }
};
