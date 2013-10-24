// Store all available maps
var g_maps = {2: [], 3: [], 4: []}

// Add a new map
function addMap(map) {
	g_maps[map.players.length] = map
}

// Get a random map with the given number of players
module.exports.getRandomMap = function (players) {
	var maps = g_maps[players]
	return maps[Math.floor(Math.random()*maps.length)]
}

// Debug map 2
addMap({size: 10,
	players: [{mana: 3}, {mana: 14}],
	cells: [
		{x: 0, y: 1, type: 1},
		{x: 2, y: 3, type: 2, owner: 0, population: 17},
		{x: 4, y: 5, type: 5, owner: 2, population: 27, level: 2}
	]
})

// Debug map 3
addMap({size: 15,
	players: [{mana: 3}, {mana: 14}, {mana: 15}],
	cells: [
		{x: 0, y: 1, type: 1},
		{x: 2, y: 3, type: 2, owner: 0, population: 17},
		{x: 4, y: 5, type: 5, owner: 2, population: 27, level: 2}
	]
})

// Debug map 4
addMap({size: 20,
	players: [{mana: 3}, {mana: 14}, {mana: 15}, {mana: 92}],
	cells: [
		{x: 0, y: 1, type: 1},
		{x: 2, y: 3, type: 2, owner: 0, population: 17},
		{x: 4, y: 5, type: 5, owner: 2, population: 27, level: 2}
	]
})
