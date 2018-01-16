// import { request } from 'http';

/**************************************************************
*  Minecraft Dashboard Backend Server
*  Author(s): Weston Clark
*
*  Description:
*  This node server will serve as a back-end for the Minecraft
*  server front end client to be able to issue commands to
*  the OS. The primary functions include stop/start the MC server,
*  run backups, and render the dynmap
*
*  File: server.js
**************************************************************
*  Change Date      Name            Description
*  =============    ===========     ==========================
*  08/05/17         Weston Clark    Initial Creation
*
**************************************************************/

// set up needed modules
const PORT = 8080;
var express = require('express')
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);
var util = require('util');
var cp = require('child_process');
var exec = cp.exec;
var spawn = cp.spawn;
var runningServers = {}
var servers = {
    minecraftServer:{
        cwd:"C:/opt/minecraft/server1",
        jar:'craftbukkit.jar',
        maxRam:'-Xmx1G',
        minRam:'-Xms512M'
    }
}
//include the modules for our server functions
var command = require('./consoleCommands');

//define how arguments are used in the terminal
var puts = function (error, stdout, stderr) {
    'use strict';
    util.print(stdout);
};

//create the server and start listening on the defined port
// var server = http.createServer();
server.listen(PORT);
console.log("Listening for a connection...");
//recieves the connection from the client and passes in a socket
io.listen(server).on('connection', (socket)=>{

    //log that we are connected
    console.log("The server and client are connected");
    socket.emit("connected");
    //listen for what method to call
    socket.on("startServer",(data)=>{
        if(data){
            var SN = data.name | 'minecraftServer'
        }else{
            var SN = 'minecraftServer'
        }
        
        // servers[SN]=spawn('java',  ['-jar','craftbukkit.jar'],  {cwd:"C:/opt/minecraft/server1", stdio:['pipe',1,1] })
        runningServers[SN]=spawn('java',  ['-jar',servers[SN].jar],  {cwd:"C:/opt/minecraft/server1", stdio:['pipe',1,1] })
    })
    socket.on("stopServer",(data)=>{
        if(data){
            var SN = data.name | 'minecraftServer'
        }else{
            var SN = 'minecraftServer'
        }
        runningServers[SN].stdin.write("stop\n")
    })
    socket.on("uninstallServer",()=>{
        exec("cd ../..; ./minecraftCommands.sh uninstall",puts)
    })
    socket.on("installServer",()=>{
        exec("cd ../..; ./minecraftCommands.sh installForge",puts)
        // console.log("Stoped Server")
    })
// I would like to use these, but module.exports aren't working right with exec()
    // socket.on("startServer",        command.startServer);
    // socket.on("stopServer",         command.stopServer);
    // socket.on("runBabkup",          command.runBabkup);
    // socket.on("renderMap",          command.renderMap);
    // socket.on("installVanillaServer",command.installVanillaServer);
    // socket.on("uninstallServer",    command.uninstallServer);
    // socket.on("installForgeServer", command.installForgeServer);
});
app.use(express.static('client'))
// app.get('*', function (req, res) {
//     res.sendfile(__dirname + '/client/');
//   });
  