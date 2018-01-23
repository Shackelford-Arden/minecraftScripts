const fs = require('fs')
const yaml = require('js-yaml');
const { join } = require('path')

function parseValue(val) {
   if (val === "") return null;
   try {
       return JSON.parse(val);
   } catch (e) {
       // do nothing, this is just a short way to extract values like:
       // true, false, [Numbers], etc.
       return val;
   }
}
var parse = function (input) {
   var output = {};
   input.split(/[\r\n]+/g).forEach(function (line) {
       if (line[0] === "#" || line.indexOf("=") < 0) return; // just a comment
       var parts = line.split("="),
           key   = parts[0].trim(),
           val   = parts[1].trim();
       if (!key) return;
       output[key] = parseValue(val);
   });
   return output;
};
function stringifyValue(val) {
   var type = typeof val;
   if (val === null) {
       return "";
   } else if (type === "boolean" || type === "number") {
       return JSON.stringify(val);
   } else {
       return val;
   }
}
var stringify = function (input) {
   var output = [], key;
   for (key in input) {
       if (input.hasOwnProperty(key)) {
           output.push(key + "=" + stringifyValue(input[key]));
       }
   }
   return output.join("\n");
};
exports.setProperties=function(server){
   var propOutString = stringify(server.properties)
   fs.writeFileSync(server.cwd+"/server.properties",propOutString)
}
exports.getProperties=function(propFile){return parse(fs.readFileSync(propFile))}
exports.getServers = function(parentDir){
   if(!parentDir)return null;
   var servers = {};
   var dirs = []
   const isDir=(source)=>{fs.lstatSync(source).isDirectory()}
   // var svrDirs=fs.readdirSync(parentDir).map(name => join(parentDir, name)).filter(isDir)
   files = fs.readdirSync(parentDir)
   console.log("files:",files)
   for(file in files){
      if(file[0] != "."){
         var filePath = parentDir+"/"+files[file]
         var stat = fs.statSync(filePath)
         if (stat.isDirectory()){
            dirs.push(files[file])
            var propFile = fs.readFileSync(parentDir+"/"+files[file]+"/server.properties",'utf-8')
            var properties = parse(propFile)
            servers[files[file]]={
               cwd: parentDir +"/"+ files[file],
               name: files[file],
               properties:properties
            }
         }
         
      }
   }
   console.log(servers)
   console.log("dirs:",dirs)
   return servers

}