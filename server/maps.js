var fs = require("fs")

// Store all available maps
var g_maps = {2: [], 3: [], 4: []}

// Load maps for the given number of players
function loadMaps(num) {
	fs.readdir("maps/" + num, function (err, files) {
		files.forEach(function (f) {
			g_maps[num].push(require("./maps/"+num+"/"+f))
		})
		console.log("Loaded "+files.length+" maps for "+num+" players")
	})
}

loadMaps(2)
loadMaps(3)
loadMaps(4)

// Get a random map with the given number of players
module.exports.getRandomMap = function (players) {
	var maps = g_maps[players]
	return maps[Math.floor(Math.random()*maps.length)]
}
