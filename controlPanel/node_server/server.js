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
var express = require('express')
var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);
// var http = require('http');
// var io   = require('socket.io');
var util = require('util');
var exec = require('child_process').exec;

//include the modules for our server functions
var command = require('./consoleCommands');

//define how arguments are used in the terminal
var puts = function (error, stdout, stderr) {
    'use strict';
    util.print(stdout);
};

//create the server and start listening on the defined port
const PORT = 8080;
// var server = http.createServer();
server.listen(PORT);
console.log("Listening for a connection...");
//recieves the connection from the client and passes in a socket
io.listen(server).on('connection', function(socket){

    //log that we are connected
    console.log("The server and client are connected");
    socket.emit("connected");

// this line starts the server. Let's build this out into the functions below    exec("/opt/mcScripts/startServer.sh", puts);

    console.log("Starting the server...");
    //listen for what method to call
    socket.on("startServer", ()=>{
        //call the tmux script to start the server
        exec("/opt/mcScripts/startServer.sh", puts);	//TODO error handel to prevent multiple instances of the server starting
    });
    socket.on("stopServer", ()=>{
        exec("killall -9 tmux", puts);
	//exec("killall -9 java", puts);    this should only be needed if the server is started using java rather then tmux
    });
//    socket.on("runBabkup",   command.runBabkup());
//    socket.on("renderMap",   command.renderMap());
});
app.use(express.static('client'))
// app.get('*', function (req, res) {
//     res.sendfile(__dirname + '/client/');
//   });
  