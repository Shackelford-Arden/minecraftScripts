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
var cp = require('child_process')
var spawn = cp.spawn
var fs = require('fs')
var runningServers = {},


//define how arguments are used in the terminal
var puts = function (error, stdout, stderr) {
  'use strict';
  console.log(stdout);
};



module.exports = {
  startServer:function(socket,SN,server){
    if (runningServers[SN] && runningServers[SN].connected) {
      var newData = {
          name: SN,
          log: SN + " Server is already running\n"
      }
      console.log(newData)
      socket.emit("stdOut", newData)
      server.log.push(newData.log);
  }

  runningServers[SN] = spawn('java', ['-jar', server.jar], {
      cwd: server.cwd,
      stdio: ['pipe', 'pipe', 'pipe']
  })
  runningServers[SN].on('error', (data) => {
      var newData = {
          name: SN,
          type: "error",
          log: data.toString() + "\n"
      }
      console.log(newData)
      socket.emit("stdOut", newData)
      server.log.push(newData.log);
  })
  runningServers[SN].stdout.on('data', (data) => {
      var newData = {
          name: SN,
          log: data.toString()
      }
      console.log(newData)
      socket.emit("stdOut", newData)
      server.log.push(newData.log);
  })
  },
  stopServer:function(socket,SN,server){
    if (runningServers[SN] && runningServers[SN].connected) {

        runningServers[SN].on('error', (data) => {
            var newData = {
                name: SN,
                type: "error",
                log: data.toString()
            }
            console.log(newData)
            socket.emit("stdOut", newData)
            server.log.push(newData.log);
        })
        console.log(runningServers[SN])
        console.log(runningServers[SN].stdin)
        runningServers[SN].stdin.write("stop\n")
    } else {
        var newData = {
            name: SN,
            type: "error",
            log: "Server " + SN + " isn't running\n"
        }
        console.log(newData)
        socket.emit("stdOut", newData)
    }
  },
  uninstallServer:function(server){
    var dir = server.cwd
    if(fs.exists(dir)){
      fs.rmdir(dir,(err)=>{
        if(err){
          console.log("Error deleting "+dir+".",err)
        }else{
          console.log("Successfuly deleted "+dir)
        }
      })
    }
  },
  installServer:function(socket,server){
    fs.mkdirSync(server.cwd);
    var file = fs.createWriteStream(server.cwd +"/vanilla.jar");
    var vanillaUrl = "https://s3.amazonaws.com/Minecraft.Download/versions/"+server.vanillaVer+"/minecraft_server."+server.vanillaVer+".jar";
    var request = http.get(vanillaUrl, function(response) {
      response.pipe(file);
    });

  }
};
