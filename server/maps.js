var fs = require("fs")

// Store all available maps
var g_maps = {2: [], 3: [], 4: []}

// Load maps for the given number of players
function loadMaps(num) {
	fs.readdir("maps/" + num, function (err, files) {
        var n = 0
		files.forEach(function (f) {
            if (f.substr(-3) == ".js") {
                n++
                g_maps[num].push(require("./maps/"+num+"/"+f))
            }
		})
		console.log("Loaded "+n+" maps for "+num+" players")
	})
}

loadMaps(2)
loadMaps(3)
loadMaps(4)

// Get a random map with the given number of players
module.exports.getRandomMap = function (players) {
	var maps = g_maps[2] // Debug: (force 2 players)
	return maps[Math.floor(Math.random()*maps.length)]
}
