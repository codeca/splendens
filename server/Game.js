"use strict"
var Player = require("./Player.js")
var config = require("./config.js")

var MSG_OUT_MATCH_DONE = 5

// Create a new game with the given players
// Randomly shuffle them
function Game(players) {
	var i, j, temp, data

	// Shuffle and save the players
	data = {players: []}
	for (i = players.length - 1; i >= 0; i--) {
		j = Math.floor(Math.random() * (i + 1))
		temp = players[i]
		players[i] = players[j]
		players[j] = temp
		
		players[i].game = this
		players[i].state = Player.STATE_INGAME
		data.players.push({name: players[i].name, id: players[i].id})
	}
	this.players = players
	
	// Alert them the match is done
	config.onmatch(data)
	players.forEach(function (p) {
		p.sendMessage(MSG_OUT_MATCH_DONE, data)
	})
}

module.exports = Game
