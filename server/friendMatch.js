// Module to handle friend matching

var MSG_FRIEND_MATCH_START = -200
var MSG_FRIEND_MATCH_JOIN = -201
var MSG_FRIEND_MATCH_NOT_FOUND = -202
var MSG_FRIEND_MATCH_PROGRESS = -203
var MSG_FRIEND_MATCH_DONE = -204
var MSG_FRIEND_MATCH_CANCELED = -205

// Try to handle a message from the player
// Return whether the message was handled by this module
module.exports.handleMessage = function handleMessage(player, type, data) {
	return false
}

// Remove a given player from the matching system
module.exports.removePlayer = function (p) {
}
