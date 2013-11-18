"use strict"
        
// Store all available maps
var _maps = {2: [], 3: [], 4: []}

// All configurations in the server side
module.exports = {
	// External host to save your local ip
	// sitegui.com.br will work for free
	externalHost: "http://sitegui.com.br/multiPlug",
	
	// Your app identifier, as shown by [[NSBundle mainBundle] bundleIdentifier]
	bundleIdentifier: "codeca.splendens",
	
	// Port to listen to
	port: 8081,
	
	// Default network interface (used with ifconfig)
	networkInterface: "en0",
	
	// Show information about connections and matching in the console
	logConnections: true,
	
	// Show information about broadcasts in the console
	logBroadcasts: false,
	
	// Minimum number of player to form a match
	minPlayers: 2,
	
	// Maximum number of player to form a match
	maxPlayers: 4,
	
	// Executed when the server is up and running
	onstart: function () {
        var fs = require("fs")
        
        // Load maps for the given number of players
        var loadMaps = function(num) {
            fs.readdir("maps/" + num, function (err, files) {
                var n = 0
                files.forEach(function (f) {
                    if (f.substr(-3) == ".js") {
                        n++
                        _maps[num].push(require("./maps/"+num+"/"+f))
                    }
                })
                console.log("Loaded "+n+" maps for "+num+" players")
            })
        }
        
        loadMaps(2)
        loadMaps(3)
        loadMaps(4)
	},
	
	// Executed when a match is found
	// data is the object that will be broadcasted to all players
	// It contains only a property, "players":
	// an array of elements with the format {data: <the custom player data>, id: ""}
	// This callback can put more fields in this object, to return more data to all players 
	onmatch: function (data) {
        console.log(data)
        var maps = _maps[data.players.length]
        data.map = maps[Math.floor(Math.random()*maps.length)]
	}
}
