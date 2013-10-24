var Player = require("./Player.js")

// Create a new game with the given players
// Randomly shuffle them
function Game(players) {
	var i, j, temp

	// Shuffle and save the players
	for (i = players.length - 1; i >= 0; i--) {
		j = Math.floor(Math.random() * (i + 1))
		players[j].game = this
		temp = players[i]
		players[i] = players[j]
		players[j] = temp
	}
	this.players = players
}

module.exports = Game
