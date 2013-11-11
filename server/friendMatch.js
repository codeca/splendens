"use strict"
// Module to handle friend matching

var Game = require("./Game.js")
var config = require("./config.js")

var MSG_OUT_FRIEND_MATCH_NOT_FOUND = 2
var MSG_OUT_FRIEND_MATCH_PROGRESS = 3
var MSG_OUT_FRIEND_MATCH_CANCELED = 4

// Store all created rooms
var _rooms = {}

// Create a new match room
module.exports.start = function (player, data) {
	var num = data.players
	if (typeof data.key != "string" || typeof num != "number" || Math.round(num) != num || num < config.minPlayers || num > config.maxPlayers) {
		log("Invalid start friend match data, closing connection")
		player.close()
		return
	}
	log("New friend match room "+data.key)
	_rooms[data.key] = {num: num, players: [player]}
	player.sendMessage(MSG_OUT_FRIEND_MATCH_PROGRESS, {wanted: num, waiting: 1})
	player.friendMatch = {key: data.key, owner: true}
}

// Try to join a match
module.exports.join = function (player, data) {
	if (typeof data.key != "string") {
		log("Invalid join friend match data, closing connection")
		player.close()
		return
	}
	if (data.key in _rooms) {
		log("Joined friend match room "+data.key)
		_rooms[data.key].players.push(player)
		tryToMatch(data.key)
		player.friendMatch = {key: data.key, owner: false}
	} else {
		log("Friend match room not found "+data.key)
		player.sendMessage(MSG_OUT_FRIEND_MATCH_NOT_FOUND)
	}
}

// Remove a given player from the matching system
module.exports.remove = function (player) {
	var match
	
	// Find the matching room
	if (player.friendMatch) {
		log("Leaving friend match room "+player.friendMatch.key)
		match = _rooms[player.friendMatch.key]
		if (match && match.players.indexOf(player) != -1) {
			if (player.friendMatch.owner) {
				// Dismiss the matching room
				match.players.forEach(function (p) {
					if (p != player)
						p.sendMessage(MSG_OUT_FRIEND_MATCH_CANCELED)
				})
				delete _rooms[player.friendMatch.key]
			} else {
				// Remove this player and update the status
				match.players = match.players.filter(function (p) {
					return p != player
				})
				tryMatch(player.friendMatch.key)
			}
		}
	}
}

// Try to finish the match with the given key
// If there isn't enough players, report the status to them
function tryToMatch(key) {
	var match = _rooms[key], data
	if (!match)
		return
	if (match.players.length == match.num) {
		// Start the game
		log("Friend match done with "+match.num+" players")
		delete _rooms[key]
		new Game(match.players)
	} else {
		// Update the status
		data = {wanted: match.num, waiting: match.players.length}
		match.players.forEach(function (p) {
			p.sendMessage(MSG_OUT_FRIEND_MATCH_PROGRESS, data)
		})
	}
}

function log(str) {
	if (config.logConnections)
		console.log("> "+str)
}
