var vanillaVer, forgeVer, newServer = {}

console.log("We are in the setup");
//   var socket =  io.connect("//64.52.84.42:8080");
var socket = io.connect(window.location.hostname + ":8080");
socket.on("connected", function () {
    console.log("Connection was made!");
});
socket.on("version", function (data) {
    vanillaVer = data;
    setVanllaDropdown(socket)
})
socket.on("stdOut", function (data) {
    console.log(data);
    var SN = data.name
    var term = document.getElementById(SN + "-stdout")
    term.innerHTML += data.log;
    term.scrollTop = term.scrollHeight
})
socket.on("servers", function (servers) {
    console.log("recieved server list: ", servers)
    $('#serverList')[0].innerHTML = null;
    for (s in servers) {
        console.log("creating server: ", s)
        createServerExpandable(s);
        var term = document.getElementById(s + "-stdout")
        for (l in servers[s].log) {
            term.innerHTML += servers[s].log[l];
            term.scrollTop = term.scrollHeight

        }
    }
})

function createServer() {
    var data = {
        servername: document.querySelector('#name').value,
        maxMem: document.querySelector('#maxMem').value,
        minMem: document.querySelector('#minMem').value,
        vanilla: document.querySelector('#vanillaVer').value,
        forge: document.querySelector('#forgeVer').value,
        isForge: document.querySelector('#forgeCheckbox').checked ? true : false
    }
    if(data.maxMem ==""){data.maxMem="1G"}
    if(data.minMem ==""){data.minMem="512mb"}
    if(data.vanilla ==""){return}
    if(data.servername ==""){return}
    console.log("Creating Server", data)
    socket.emit("createServer", data,function(log){
        console.log("CreateServer returnFunction:",log)
        $('#creationMessage')[0].innerHTML = log;
    })
}

function startServer(SN) {
    console.log("startingServer:", SN)
    var data = {
        name: SN
    }
    socket.emit("startServer", data);
}

function stopServer(SN) {
    console.log("stopingServer:", SN)
    var data = {
        name: SN
    }
    socket.emit("stopServer", data);
}

function editServer() {
    console.log("Gonna edit something")
}

function uninstallServer() {
    console.log("removing server installation")
    socket.emit("uninstallServer");
}

function installServer() {
    console.log("creating server installation")
    socket.emit("installServer");
}


function connectedToServer() {
    console.log("Connection to the server was established...");
}
$(document).ready(function () {
    $('select').material_select();
    $('form').submit(function (e) {
        return false;
    })
    $('#vanillaVer')[0].onchange = function () {
        getForgeDropdown()
    }
});

function setVanllaDropdown(socket) {
    var dropdown = $('#vanillaVer')[0];
    dropdown.innerHTML = "";
    // dropdown.appendChild
    var v = vanillaVer.versions
    console.log(vanillaVer);
    var blank = newElem(dropdown, "option", []);
    blank.setAttribute("value", "")
    blank.disabled = true;
    blank.selected = true;
    // dropdown.appendChild(opt)
    for (i in v) {
        var opt = newElem(dropdown, "option", []);
        opt.setAttribute("value", v[i])
        opt.innerHTML = v[i]
        if (v[i] == vanillaVer.recommended) {
            opt.selected = true;
        }
        dropdown.appendChild(opt)
    }
    $('select').material_select();
    getForgeDropdown()
}

function getForgeDropdown() {
    var selVer = $('#vanillaVer')[0].value
    console.log("Selected vanilla ver: ", selVer)
    console.log("getting forge version")


    socket.emit("getForgeVersions", selVer, function (data) {
        console.log("inside emit return funciton: Forge: ", data)
        forgeVer = data;
        // TODO: remove dropdown options
        var dropdown = $('#forgeVer')[0];
        dropdown.innerHTML = "";

        var v = forgeVer.versions
        console.log("forgeVer: ", forgeVer);

        // TODO: create dropdown options
        var blank = newElem(dropdown, "option", []);
        blank.setAttribute("value", "")
        blank.disabled = true;
        blank.selected = true;
        for (i in v) {
            var opt = newElem(dropdown, "option", []);
            opt.setAttribute("value", v[i])
            opt.innerHTML = v[i]
            if (v[i] == forgeVer.recommended) {
                opt.selected = true;
            }
            dropdown.appendChild(opt)
        }
        // TODO: Initialize the dropdown
        $('select').material_select();
    })
}

function createServerExpandable(serverName) {
    var list = $('#serverList')[0],
        li = newElem(list, "li"),
        head = newElem(li, "div", ["collapsible-header"]),
        name = newElem(head, "div", ["serverName"]),
        status = newElem(head, "div", ["serverStatus"]),
        spacer = newElem(head, "div", ["spacer"]),
        start = newElem(head, "div", ["startServer"]),
        stop = newElem(head, "div", ["stopServer"]),
        startBtn = newElem(start, 'a', ["waves-effect", "waves-light", "btn"]),
        stopBtn = newElem(stop, 'a', ["waves-effect", "waves-light", "btn"]),
        body = newElem(li, "div", ["collapsible-body"]),
        term = newElem(body, "div", ["terminal", "space", "shadow"]),
        ttop = newElem(term, "div", ["top"]),
        tbtns = newElem(ttop, "div", ["btns"]),
        tred = newElem(tbtns, "div", ["circle", "red"]),
        tyellow = newElem(tbtns, "div", ["circle", "yellow"]),
        tgreen = newElem(tbtns, "div", ["circle", "green"]),
        ttitle = newElem(ttop, "div", ["title"]),
        tpre = newElem(term, "pre", ["body"])
    name.innerHTML = serverName;
    ttitle.innerHTML = serverName;
    tpre.setAttribute('id', serverName + "-stdout")
    startBtn.innerHTML = "Start";
    startBtn.setAttribute("serverName", serverName)
    $('.collapsible').collapsible();
    startBtn.addEventListener("click", function (event) {
        console.log(event)
        var SN = serverName;
        startServer(SN)
        event.preventDefault();
        event.stopPropagation();
    })
    stopBtn.innerHTML = "Stop";
    stopBtn.setAttribute("serverName", serverName)
    stopBtn.addEventListener("click", function (event) {
        console.log(event)
        stopServer(serverName)
        event.preventDefault()
        event.stopPropagation()
    })

}





function newElem(parent, type, classList) {
    var elem = document.createElement(type)
    if (classList) {
        for (i in classList)
            elem.classList.add(classList[i])
    }
    parent.appendChild(elem);
    return elem;
}