// import { request } from 'http';

/**************************************************************
*  Minecraft Dashboard Backend Server
*  Author(s): Weston Clark,Cody Nichols
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
*  01/17/18         Cody Nichols    Changed A Lot...
*
**************************************************************/

// set up needed modules
const PORT = 8080;
var express = require('express'),
    app = express(),
    server = require('http').Server(app),
    http = require('http'),
    io = require('socket.io')(server),
    util = require('util'),
    cp = require('child_process'),
    exec = cp.exec,
    spawn = cp.spawn,
    runningServers = {},
    request = require('request'),
    cheerio = require('cheerio');
    vanillaVerion=getVanillaVersions(),
    forgeVersion=getForgeVersions(vanillaVerion.recommended),
console.log("vanilla: ",vanillaVerion)
console.log("forge:   ",forgeVersion)
getVanillaVersions()
getForgeVersions()

if(process.platform == "win32"){var installDirParent = "C:/opt/minecraft/"}else{var installDirParent = "/opt/minecraft/"}
console.log("Platform: ",process.platform)
var servers = {
    minecraftServer:{
        cwd:installDirParent+"server1",
        name:"minecraftServer",
        jar:'craftbukkit.jar',
        maxRam:'-Xmx1G',
        minRam:'-Xms512M',
        log:[]
    },
    bukkit:{
        cwd:"/opt/minecraft/server2",
        name:"bukkit",
        jar:'craftbukkit.jar',
        maxRam:'-Xmx1G',
        minRam:'-Xms512M',
        log:[]
    }
}
console.log("servers: ",servers)
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
    socket.emit("servers",servers)
    // socket.emit("fver",forgeVersion)
    socket.emit("version",vanillaVerion)
    //listen for what method to call
    socket.on("getForgeVersions",(vanillaVer)=>{
        return getForgeVersions(vanillaVer)
    })
    socket.on("startServer",(data)=>{
        if(data){
            var SN = data.name
        }else{
            var SN = 'minecraftServer'
        }
        if(runningServers[SN] && runningServers[SN].connected){
            var newData = {
                name:SN,
                log:SN+" Server is already running\n"
            }
            console.log(newData)
            socket.emit("stdOut",newData)
            servers[SN].log.push(newData.log);
        }
        // servers[SN]=spawn('java',  ['-jar','craftbukkit.jar'],  {cwd:"C:/opt/minecraft/server1", stdio:['pipe',1,1] })

            runningServers[SN]=spawn('java',  ['-jar',servers[SN].jar],  {cwd:servers[SN].cwd, stdio:['pipe','pipe','pipe'] })
            runningServers[SN].on('error',(data)=>{
                var newData = {
                    name:SN,
                    type:"error",
                    log:data.toString()+"\n"
                }
                console.log(newData)
                socket.emit("stdOut",newData)
                servers[SN].log.push(newData.log);
            })
            runningServers[SN].stdout.on('data',(data)=>{
                var newData = {
                    name:SN,
                    log:data.toString()
                }
                console.log(newData)
                socket.emit("stdOut",newData)
                servers[SN].log.push(newData.log);
            })
        
    })
    socket.on("stopServer",(data)=>{
        if(data){
            var SN = data.name
        }else{
            var SN = 'minecraftServer'
        }
        if(runningServers[SN] && runningServers[SN].connected){

            runningServers[SN].on('error',(data)=>{
                var newData = {
                    name:SN,
                    type:"error",
                    log:data.toString()
                }
                console.log(newData)
                socket.emit("stdOut",newData)
                servers[SN].log.push(newData.log);
            })
            console.log(runningServers[SN])
            console.log(runningServers[SN].stdin)
            runningServers[SN].stdin.write("stop\n")
        }else{
            var newData = {
                name:SN,
                type:"error",
                log:"Server "+SN+" isn't running\n"
            }
            console.log(newData)
            socket.emit("stdOut",newData)
        }})

        socket.on("uninstallServer",()=>{
        exec("cd ../..; ./minecraftCommands.sh uninstall",puts)
    })
    socket.on("installServer",()=>{
        exec("cd ../..; ./minecraftCommands.sh installForge",puts)
        // console.log("Stoped Server")
    })

});
app.use(express.static('client'))
  



    // Get latest Vanilla 
function getVanillaVersions(){
    var retData ={
        recommended:"",
        versions:[]
    }

    http.get("http://launchermeta.mojang.com/mc/game/version_manifest.json",(response)=>{
        body=""
        response.on("data",(chunk)=>{
            body += chunk;
        })
        response.on('end',()=>{
            if(response.statusCode === 200){
                try{
                    var tmpJSON=JSON.parse(body)
                    retData.recommended = tmpJSON.latest.release
                    for (v in tmpJSON.versions){
                        if(tmpJSON.versions[i].type == 'release')
                        retData.versions.push(tmpJSON.versions[i].id)
                    }
                }catch(error){
                    retData.versions=['1.12.2'];retData.recommended='1.12.2';
                }
            }else{
                retData.versions=['1.12.2'];retData.recommended='1.12.2';
            }
        })
    })
    return retData;
} 
function getForgeVersions(vanillaVer){
    var retData ={
        recommended:"",
        versions:[]
    }
    if(vanillaVer){
        url = 'http://files.minecraftforge.net/maven/net/minecraftforge/forge/index_'+vanillaVer+'.html';
    }else{
        url = 'http://files.minecraftforge.net/';
    }
    request(url, function(error, response, html){
    if(!error){
        var $ = cheerio.load(html);
        $('.promos-content .download .promo-recommended~small').filter(function(){
            var data = $(this);
            retData.recommended = data.text();
        })
        $('.download-list tbody td.download-version').filter(function(){
            var data = $(this);
            retData.versions.push(data.text().trim())
        })
        }
    })
    return retData;
}
