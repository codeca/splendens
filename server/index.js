"use strict"
var Player = require("./Player.js")
var simpleMatch = require("./simpleMatch.js")
var friendMatch = require("./friendMatch.js")
var config = require("./config.js")
var _totalConnections = 0

// Get the local ip for this machine and save in an external host
require("child_process").exec("ifconfig "+config.networkInterface, function (error, stdout, stderr) {
	var ips, localIpIndex, options
	if (error)
		throw new Error("Error")

	// Get all ips
	ips = stdout.toString().match(/\b(\d{1,3}\.){3}\d{1,3}\b/g)
	localIpIndex = 0
	if (!ips || !ips[localIpIndex])
		throw new Error("Local ip not found")

	// Send to server
	console.log("> Saving your local ip (" + ips[localIpIndex] + ") to external host (" + config.externalHost+") ...")
    options = require("url").parse(config.externalHost+"/set.php?key="+config.bundleIdentifier+"&ip="+ips[localIpIndex])
    options.agent = false
	require("http").get(options, function (res) {
		if (res.statusCode != 200)
			throw new Error("Error in the request. Check your Internal connection and your config.js fields")
	}).once("close", function () {
		console.log("> Saved, starting server...")
		startServer()
	})
})

// Constants
var MSG_OUT_PLAYER_DISCONNECTED = -1
var MSG_IN_SIMPLE_MATCH = 0
var MSG_IN_FRIEND_MATCH_START = 1
var MSG_IN_FRIEND_MATCH_JOIN = 2

// Treat each new message from a device
function onmessage(type, data) {
	if (this.state == Player.STATE_NONE) {
		if (!data || !("data" in data) || typeof data.id != "string") {
			// Invalid data
			if (config.logConnections)
				console.log("> Invalid match data, closing connection")
			this.close()
			return
		}
		this.data = data.data
		this.id = data.id
		
		if (type == MSG_IN_SIMPLE_MATCH) {
			// Simple match started
			this.state = Player.STATE_MATCHING_SIMPLE
			simpleMatch.start(this, data)
		} else if (type == MSG_IN_FRIEND_MATCH_START) {
			// Friend match started
			this.state = Player.STATE_MATCHING_FRIEND
			friendMatch.start(this, data)
		} else if (type == MSG_IN_FRIEND_MATCH_JOIN) {
			// Friend match started (accepted an invite)
			this.state = Player.STATE_MATCHING_FRIEND
			friendMatch.join(this, data)
		} else {
			// Invalid type
			if (config.logConnections)
				console.log("> Invalid match type, closing connection")
			this.close()
		}
	} else if (this.state == Player.STATE_INGAME) {
		// Broadcast the message
        if (type < 0)
            return
		if (config.logBroadcasts)
			console.log("> Broadcasting", type, data)
		this.broadcast(type, data)
	}
}

// Treat a player disconnection
function onclose() {
	if (this.game)
		// Tell other players in the same room this one has disconnected
		this.broadcast(MSG_OUT_PLAYER_DISCONNECTED, this.id)
	else if (this.state == Player.STATE_MATCHING_SIMPLE)
		simpleMatch.remove(this)
	else if (this.state == Player.STATE_MATCHING_FRIEND)
		friendMatch.remove(this)
	
	// Log
	_totalConnections--
	if (config.logConnections)
		console.log("> Connection closed ("+_totalConnections+" active connections)")
}

// Create the server to answer each new connection
function startServer() {
	var server = require("net").createServer(function (conn) {
		// Create the player
		var p = new Player(conn)
		p.on("message", onmessage)
		p.on("close", onclose)
		
		// Log
		_totalConnections++
		if (config.logConnections)
			console.log("> New connection ("+_totalConnections+" active connections)")
	})
	server.listen(config.port)
	server.on("listening", function () {
		console.log("> Server started")
		config.onstart()
	})
}
