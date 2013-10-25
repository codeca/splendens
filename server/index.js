var Player = require("./Player.js")
var simpleMatch = require("./simpleMatch.js")
var friendMatch = require("./friendMatch.js")
var getRandomMap = require("./maps.js").getRandomMap

require("./setIp.js")

// Constants
var MSG_DEBUG = -2
var MSG_PLAYER_DISCONNECTED = -1
var MATCH_TYPE_UNKNOW = 0
var MATCH_TYPE_SIMPLE = 1
var MATCH_TYPE_FRIEND = 2

// Try to remove an element from an array
function removeFromArray(a, el) {
	var pos = a.indexOf(el)
	if (pos != -1)
		a.splice(pos, 1)
}

// Send the given message to all the players in the array
// ignoreThis is a player to whon the message won't be sent (optional)
function broadcast(players, type, data, ignoreThis) {
	players.forEach(function (p) {
		if (p != ignoreThis)
			p.sendMessage(type, data)
	})
}

// Treat each new message from a device
function onmessage(type, data) {
    if (MSG_DEBUG) {
        // Debug
        this.sendMessage(MSG_DEBUG, getRandomMap(Math.floor(Math.random()*3)+2))
    } else if (this.game) {
		// Broadcast the message
		broadcast(this.game.players, type, data, this)
	} else if (simpleMatch.handleMessage(this, type, data))
		// Simple match started
		this.matchType = MATCH_TYPE_SIMPLE
	else if (friendMatch.handleMessage(this, type, data))
		// Friend match started
		this.matchType = MATCH_TYPE_FRIEND
}

// Treat a player disconnection
function onclose() {
	if (this.game) {
		// Tell other players in the same room this one has disconnected
		removeFromArray(this.game.players, this)
		broadcast(this.game.players, MSG_PLAYER_DISCONNECTED, this.id)
	} else if (this.matchType == MATCH_TYPE_SIMPLE)
		simpleMatch.removePlayer(this)
	else if (this.matchType == MATCH_TYPE_FRIEND)
		friendMatch.removePlayer(this)
}

// Create the server to answer each new connection
require("net").createServer(function (conn) {
	var p = new Player(conn)
	p.matchType = MATCH_TYPE_UNKNOW
	p.on("message", onmessage)
	p.on("close", onclose)
}).listen(8001)
