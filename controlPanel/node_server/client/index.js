function connectedToServer(){
   console.log("Connection to the server was established...");
}

function createServerExpandable(serverName){
   var list = $('#serverList'),
         li = newElem(list,"li"),
         head = newElem(li,"div",["collapsible-header"]),
         name = newElem(head,"div",["serverName"]),
         status = newElem(head,"div",["serverStatus"]),
         spacer = newElem(head,"div",["spacer"]),
         start = newElem(head,"div",["startServer"]),
         stop = newElem(head,"div",["stopServer"]),
         startBtn = newElem(start,'a',["waves-effect","waves-light","btn"]),
         stopBtn = newElem(stop,'a',["waves-effect","waves-light","btn"])
   startBtn.innerHTML = "Start";
   startBtn.setAttribute("serverName",serverName)
   startBtn.addEventListener("click",function(event){
      startServer()
      event.preventDefault();
   })
   stopBtn.innerHTML = "Stop";
   stopBtn.setAttribute("serverName",serverName)
   stopBtn.addEventListener("click",function(event){
      stopServer()
      event.preventDefault();
   })
}

function newElem(parent,type,classList){
   var elem = Document.createElement(type)
   if(classList){
      for(i in classList)
      elem.classList.add(i)
   }
   return elem;
}