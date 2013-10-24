// Module to handle simple matching

var Game = require("./Game.js")
var getRandomMap = require("./maps.js").getRandomMap

var MSG_SIMPLE_MATCH = -100
var MSG_SIMPLE_MATCH_PROGRESS = -101
var MSG_SIMPLE_MATCH_DONE = -102

// Store all waiting players
var g_room = []

// Indicate the number of players waiting for each number of players in a game
var g_n2 = g_n3 = g_n4 = 0

// Try to handle a message from the player
// Return whether the message was handled by this module
module.exports.handleMessage = function handleMessage(player, type, data) {
	if (type == MSG_SIMPLE_MATCH) {
		// Gather the data
		player.want2 = Boolean(data.want2)
		player.want3 = Boolean(data.want3)
		player.want4 = Boolean(data.want4)
		player.name = String(data.name)
		player.id = String(data.id)

		// Update the waiting room
		g_room.push(player)
		if (player.want2) g_n2++
		if (player.want3) g_n3++
		if (player.want4) g_n4++

		// Check possible matches or just update the status to everybody
		if (g_n4 == 4)
			createMatch(4)
		else if (g_n3 == 3)
			createMatch(3)
		else if (g_n2 == 2)
			createMatch(2)
		else
			informProgress()

		return true;
	}
	return false;
}

// Remove a given player from the matching system
module.exports.removePlayer = function (p) {
	var pos = g_room.indexOf(p)
	if (pos != -1) {
		g_room.splice(pos, 1)
		if (p.waitingFor2) g_n2--
		if (p.waitingFor3) g_n3--
		if (p.waitingFor4) g_n4--
		informProgress()
	}
}

// Create a match with the given number of players
// There must be exactly "num" players wanting to play with "num" players
function createMatch(num) {
	var players, allPlayers, data

	// Separate the players and update status
	g_n2 = g_n3 = g_n4 = 0
	allPlayers = g_room
	players = []
	g_room = []
	allPlayers.forEach(function (p) {
		if (p["want" + num])
			players.push(p)
		else {
			g_room.push(p)
			if (p.want2) g_n2++
			if (p.want3) g_n3++
			if (p.want4) g_n4++
		}
	})

	// Create the game and inform those players
	new Game(players)
	data = {map: getRandomMap(num), players: []}
	players.forEach(function (p) {
		data.players.push({name: p.name, id: p.id})
	})
	players.forEach(function (p) {
		p.sendMessage(MSG_SIMPLE_MATCH_DONE, data)
	})

	// Send the updated status to the others
	informProgress()
}

// Inform all players currently waiting the matching progress
function informProgress() {
	var data = {waitingFor2: g_n2, waitingFor3: g_n3, waitingFor4: g_n4}
	g_room.forEach(function (p) {
		p.sendMessage(MSG_SIMPLE_MATCH_PROGRESS, data)
	})
}
