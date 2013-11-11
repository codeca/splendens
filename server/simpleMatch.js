"use strict"
// Module to handle simple matching

var Game = require("./Game.js")
var config = require("./config.js")

var MSG_OUT_SIMPLE_MATCH_PROGRESS = 1

// Storage to all waiting players
var _rooms = (function () {
	var r = [], n
	for (n=config.maxPlayers; n>=config.minPlayers; n--)
		r[n] = []
	return r
})()

// Handle a new player in the line
module.exports.start = function (player, data) {
	var i, num
	
	// Validate the input
	if (!Array.isArray(data.wishes)) {
		log("Invalid start simple match data, closing connection")
		player.close()
		return
	}
	for (i=0; i<data.wishes.length; i++) {
		num = data.wishes[i]
		if (typeof num != "number" || Math.round(num) != num || num < config.minPlayers || num > config.maxPlayers) {
			log("Invalid start simple match data, closing connection")
			player.close()
			return
		}
	}
	
	// Add to the rooms and check if a match can be done
	data.wishes.sort(function (a, b) {
		return b-a
	})
	log("New player waiting for "+data.wishes.join(" or ")+" players")
	for (i=0; i<data.wishes.length; i++) {
		num = data.wishes[i]
		_rooms[num].push(player)
		if (_rooms[num].length == num) {
			// Create the match
			doMatch(num)
			break
		}
	}
	
	// Inform everybody about the status
	informProgress()
}

// Remove a given player from the matching system
module.exports.remove = function (player) {
	var n, pos
	
	// Remove from all rooms
	log("Player leaving simple match")
	for (n=config.maxPlayers; n>=config.minPlayers; n--) {
		pos = _rooms[n].indexOf(player)
		if (pos != -1)
			_rooms[n].splice(pos, 1)
	}
	
	// Inform everybody about the status
	informProgress()
}

// Create a match with the given number of players
function doMatch(num) {
	var players, n, pos, j, before
	players = _rooms[num]
	log("Simple match done with "+num+" players")
	
	// Remove these players from all other rooms
	for (n=config.maxPlayers; n>=config.minPlayers; n--) {
		if (n == num)
			continue
		before = _rooms[n]
		_rooms[n] = []
		for (j=0; j<before.length; j++)
			if (players.indexOf(before[j]) == -1)
				_rooms[n].push(before[j])
	}
	
	new Game(players)
	_rooms[num] = []
}

// Send to every body in the waiting room the current status of all rooms
function informProgress() {
	var data, n, idsAlerted, i, player
	
	// Collect all data
	data = []
	for (n=config.maxPlayers; n>=config.minPlayers; n--)
		data.push({wanted: n, waiting: _rooms[n].length})
	
	// Broadcast
	idsAlerted = {}
	for (n=config.maxPlayers; n>=config.minPlayers; n--)
		for (i=0; i<_rooms[n].length; i++) {
			player = _rooms[n][i]
			if (!(player.id in idsAlerted)) {
				player.sendMessage(MSG_OUT_SIMPLE_MATCH_PROGRESS, data)
				idsAlerted[player.id] = true
			}
		}
}

function log(str) {
	if (config.logConnections)
		console.log("> "+str)
}
