function connectedToServer(){
   console.log("Connection to the server was established...");
}

function createServerExpandable(serverName){
   var list = $('#serverList')[0],
         li = newElem(list,"li"),
         head = newElem(li,"div",["collapsible-header"]),
         name = newElem(head,"div",["serverName"]),
         status = newElem(head,"div",["serverStatus"]),
         spacer = newElem(head,"div",["spacer"]),
         start = newElem(head,"div",["startServer"]),
         stop = newElem(head,"div",["stopServer"]),
         startBtn = newElem(start,'a',["waves-effect","waves-light","btn"]),
         stopBtn = newElem(stop,'a',["waves-effect","waves-light","btn"]),
         body = newElem(li,"div",["collapsible-body"]),
         term = newElem(body,"div",["terminal","space","shadow"]),
         ttop = newElem(term,"div",["top"]),
         tbtns = newElem(ttop,"div",["btns"]),
         tred = newElem(tbtns,"div",["circle","red"]),
         tyellow = newElem(tbtns,"div",["circle","yellow"]),
         tgreen = newElem(tbtns,"div",["circle","green"]),
         ttitle = newElem(ttop,"div",["title"]),
         tpre = newElem(term,"pre",["body"])
   name.innerHTML=serverName;
   ttitle.innerHTML=serverName;
   tpre.setAttribute('id',serverName+"-stdout")
   startBtn.innerHTML = "Start";
   startBtn.setAttribute("serverName",serverName)
   startBtn.addEventListener("click",function(event){
      console.log(event)
      var SN = serverName;
      startServer(SN)
      event.preventDefault();
   })
   stopBtn.innerHTML = "Stop";
   stopBtn.setAttribute("serverName",serverName)
   stopBtn.addEventListener("click",function(event){
      console.log(event)
      stopServer(serverName)
      event.preventDefault();
   })

   $('.collapsible').collapsible();
}





function newElem(parent,type,classList){
   var elem = document.createElement(type)
   if(classList){
      for(i in classList)
      elem.classList.add(classList[i])
   }
   parent.appendChild(elem);
   return elem;
}