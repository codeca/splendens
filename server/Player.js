// Represent each player connected to the server
// Create a new player with new Player(socket_connection)
// socket_connection must be an open client socket
// Emits close() and message(name, data) events
function Player(conn) {
	// Indicate whether the connection is open
	this.connected = true
	this.game = null
	
	// Internal data
	this._conn = conn
	this._conn.on("readable", this._getOnreadable())
	this._conn.on("close", this._getOnclose())
	this._conn.on("error", this._onerror)
	this._readBuffer = new Buffer(0)
}

// Export the Player class and make it extends EventEmitter
module.exports = Player
var events = require("events")
var util = require("util")
util.inherits(Player, events.EventEmitter)

// Send the given named message to the client
// type is an int and data is anything that can be transformed into JSON
Player.prototype.sendMessage = function (type, data) {
	var buffer, len, lenBuffer
	data = data===undefined ? null : data
	buffer = new Buffer(JSON.stringify([type, data]))
	len = buffer.length
	lenBuffer = new Buffer([len>>16, (len>>8)%256, len%256])
	this._conn.write(lenBuffer)
	this._conn.write(buffer)
}

// Close the given connection and prevent future messages to be processed
Player.prototype.close = function () {
	this.connected = false
	this._conn.end()
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
	// Go on extracting all messages
	while (true) {
		if (!this.connected)
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
		message = JSON.parse(messageBuffer.toString())
		this.emit("message", message[0], message[1])
	}
}

// Treat close event
Player.prototype._getOnclose = function () {
	var that = this
	return function () {
		that.connected = false
		that.emit("close")
		that._conn = null
	}
}

// Just let the connection be closed
Player.prototype._onerror = function () {}
