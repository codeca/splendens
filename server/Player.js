"use strict"
// Represent each player connected to the server
// Create a new player with new Player(socket_connection)
// socket_connection must be an open client socket
// Emits close() and message(name, data) events
function Player(conn) {
	// A reference to the game this player is in
	this.game = null
	
	// The current player state (see Player.STATE_* constants)
	this.state = Player.STATE_NONE
	
	// The player name (sent by the iOS)
	this.name = ""
	
	// An unique id for the player (sent by the iOS)
	this.id = ""
	
	// Internal data
	this._conn = conn
	this._conn.on("readable", this._getOnreadable())
	this._conn.on("close", this._getOnclose())
	this._conn.on("error", this._onerror)
	this._readBuffer = new Buffer(0)
}

// Export the Player class and make it extends EventEmitter
module.exports = Player
require("util").inherits(Player, require("events").EventEmitter)

// Player states
Player.STATE_NONE = 0 // The player has just connected
Player.STATE_MATCHING_SIMPLE = 1 // The player is waiting for a simple match
Player.STATE_MATCHING_FRIEND = 2 // The player is waiting for a match with a friend
Player.STATE_INGAME = 3 // The player has already matched and is in a gem
Player.STATE_DISCONNECTED = 4 // The player lost connection to the server

// Send the given named message to the client
// type is an int and data is anything that can be transformed into JSON
Player.prototype.sendMessage = function (type, data) {
	var buffer, len, lenBuffer
	if (this.state != Player.STATE_DISCONNECTED && this._conn) {
		data = data===undefined ? null : data
		buffer = new Buffer(JSON.stringify([type, data]))
		len = buffer.length
		lenBuffer = new Buffer([len>>16, (len>>8)%256, len%256])
		this._conn.write(lenBuffer)
		this._conn.write(buffer)
	}
}

// Close the given connection and prevent future messages to be processed
Player.prototype.close = function () {
	this.state = Player.STATE_DISCONNECTED
	this._conn.end()
}

// Broadcast a message to all players in the same game as this one
Player.prototype.broadcast = function (type, data) {
	var that = this, buffer, len, lenBuffer
	if (this.game) {
		// Create the buffers
		data = data===undefined ? null : data
		buffer = new Buffer(JSON.stringify([type, data]))
		len = buffer.length
		lenBuffer = new Buffer([len>>16, (len>>8)%256, len%256])
		
		this.game.players.forEach(function (player) {
			if (player._conn && player != that && player.state != Player.STATE_DISCONNECTED) {
				player._conn.write(lenBuffer)
				player._conn.write(buffer)
			}
		})
	}
}

// Read incoming data
Player.prototype._getOnreadable = function () {
	var that = this
	return function () {
		var buffer, len, messageBuffer, message
		
		// Read the data
		buffer = that._conn.read()
		if (buffer) {
			that._readBuffer = Buffer.concat([that._readBuffer, buffer], that._readBuffer.length+buffer.length)
			that._processMessages()
		}
	}
}

// Try to process messages out of the read buffer
Player.prototype._processMessages = function () {
    var len, messageBuffer, message
    
	// Go on extracting all messages
	while (true) {
		if (this.state == Player.STATE_DISCONNECTED)
			return

		if (this._readBuffer.length < 3)
			return
		
		// Get the message length
		len = (this._readBuffer[0]<<16)+(this._readBuffer[1]<<8)+this._readBuffer[2]
		if (this._readBuffer.length < 3+len)
			return
		
		// Extract this message from the current buffer
		messageBuffer = this._readBuffer.slice(3, 3+len)
		this._readBuffer = this._readBuffer.slice(3+len)
		
		// Inflate the data and emit the event
		try {
			message = JSON.parse(messageBuffer.toString())
		} catch (e) {
			this.close()
		}
		if (Array.isArray(message) && message.length == 2)
			this.emit("message", message[0], message[1])
		else
			this.close()
	}
}

// Treat close event
Player.prototype._getOnclose = function () {
	var that = this
	return function () {
		that.state = Player.STATE_DISCONNECTED
		that.emit("close")
		that._conn = null
	}
}

// Just let the connection be closed
Player.prototype._onerror = function () {}
