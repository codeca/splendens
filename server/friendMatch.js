// Module to handle friend matching

var Game = require("./Game.js")
var getRandomMap = require("./maps.js").getRandomMap

var MSG_FRIEND_MATCH_START = -200
var MSG_FRIEND_MATCH_JOIN = -201
var MSG_FRIEND_MATCH_NOT_FOUND = -202
var MSG_FRIEND_MATCH_PROGRESS = -203
var MSG_FRIEND_MATCH_DONE = -204
var MSG_FRIEND_MATCH_CANCELED = -205

// Store all created rooms
var g_rooms = {}

// Try to handle a message from the player
// Return whether the message was handled by this module
module.exports.handleMessage = function handleMessage(player, type, data) {
	if (type == MSG_FRIEND_MATCH_START) {
		// Gather the data
		player.name = String(data.name)
		player.id = String(data.id)

		// Create the room
		g_rooms[data.key] = {num: Number(data.players), players: [player]}
	} else if (type == MSG_FRIEND_MATCH_JOIN) {
		if (data.key in g_rooms) {
			player.name = String(data.name)
			player.id = String(data.id)
			g_rooms[data.key].players.push(player)
			tryToMatch(data.key)
		} else
			player.sendMessage(MSG_FRIEND_MATCH_NOT_FOUND)
	}
	return false
}

// Remove a given player from the matching system
module.exports.removePlayer = function (p) {
	var match

	// Try to find the player in any room
	for (key in g_rooms) {
		match = g_rooms[key]
		if (match.players.indexOf(p) != -1) {
			match.players.forEach(function (p2) {
				if (p2 != p)
					p2.sendMessage(MSG_FRIEND_MATCH_CANCELED)
			})
			delete g_rooms[key]
			break
		}
	}
}

// Try to finish the match with the given key
// If there isn't enough players, report the status to them
function tryToMatch(key) {
	var match = g_rooms[key], data
	if (match.players.length == match.num) {
		// Start the game
		delete g_rooms[key]
		new Game(match.players)
		data = {map: getRandomMap(match.num), players: []}
		match.players.forEach(function (p) {
			data.players.push({name: p.name, id: p.id})
		})
		match.players.forEach(function (p) {
			p.sendMessage(MSG_FRIEND_MATCH_DONE, data)
		})
	} else {
		// Update the status
		data = {wanted: match.num, waiting: match.players.length}
		match.players.forEach(function (p) {
			p.sendMessage(MSG_FRIEND_MATCH_PROGRESS, data)
		})
	}
}
