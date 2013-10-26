"use strict"

var map = []
var mapSize = 20
var activeTool = ""

// Allocate a 20*20 empty map
function clearMap() {
	var i, j
	for (i = 0; i < 20; i++) {
		map[i] = []
		for (j = 0; j < 20; j++)
			map[i][j] = {type: 0}
	}
}
clearMap()

// Create the divs for the given map size
function setMapSize(size) {
	var x, y, mapDiv, div, divs
	mapDiv = document.getElementById("map")
	mapDiv.className = size == 10 ? "map-small" : (size == 15 ? "map-medium" : "map-large")
	while (mapDiv.children.length > 1)
		mapDiv.removeChild(mapDiv.children.item(1))
	for (y = 0; y < size; y++) {
		for (x = 0; x < size; x++) {
			div = document.createElement("div")
			div.className = "cell"
			div.onclick = cellOnClick
			div.onmousedown = cellOnMouseDown
			div.onmousemove = cellOnMouseMove
			div.dataset.x = x
			div.dataset.y = y
			div.style.backgroundImage = cell2image(x, y)
			if (map[x][y].type > 1)
				div.innerHTML = map[x][y].population
			if (map[x][y].type > 2)
				setStars(div, map[x][y].level-1)
			mapDiv.appendChild(div)
		}
	}
	mapSize = size
}

// Return the right image name for the cell in the given position
// stop indicate whether wall texture updates should not propagate (used by the recursion)
function cell2image(x, y, stop) {
	var cell, neighbourhood, masks, values, imageNames, i, angles, r
	
	// Look for neighbours
	neighbourhood = 0
	if (x < mapSize-1 && y < mapSize-1 && map[x+1][y+1].type == 1) {
		neighbourhood += 1
		if (!stop)
			cell2image(x+1, y+1, true)
	}
	if (x > 0 && y < mapSize-1 && map[x-1][y+1].type == 1) {
		neighbourhood += 2
		if (!stop)
			cell2image(x-1, y+1, true)
	}
	if (x > 0 && y > 0 && map[x-1][y-1].type == 1) {
		neighbourhood += 4
		if (!stop)
			cell2image(x-1, y-1, true)
	}
	if (x < mapSize-1 && y > 0 && map[x+1][y-1].type == 1) {
		neighbourhood += 8
		if (!stop)
			cell2image(x+1, y-1, true)
	}
	if (y < mapSize-1 && map[x][y+1].type == 1) {
		neighbourhood += 16
		if (!stop)
			cell2image(x, y+1, true)
	}
	if (x > 0 && map[x-1][y].type == 1) {
		neighbourhood += 32
		if (!stop)
			cell2image(x-1, y, true)
	}
	if (y > 0 && map[x][y-1].type == 1) {
		neighbourhood += 64
		if (!stop)
			cell2image(x, y-1, true)
	}
	if (x < mapSize-1 && map[x+1][y].type == 1) {
		neighbourhood += 128
		if (!stop)
			cell2image(x+1, y, true)
	}
	
	cell = map[x][y]
	if (cell.type == 0)
		return "url(imgs/empty.png)"
	if (cell.type == 1) {
		// Pick the right image name and rotation
		masks = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 6, 6, 6, 6, 12, 12, 12, 12, 9, 9, 9, 9, 7, 7, 15, 11, 11, 14, 14, 15, 13, 13, 15, 15, 15, 15, 15]
		values = [255, 254, 253, 251, 247, 252, 250, 246, 249, 245, 243, 248, 244, 242, 241, 240, 239, 235, 231, 227, 223, 222, 215, 214, 191, 190, 189, 188, 127, 125, 123, 121, 199, 207, 175, 107, 111, 158, 159, 95, 61, 63, 143, 79, 47, 31, 15]
		imageNames = ["0f", "0e", "0e", "0e", "0e", "0c", "0d", "0c", "0c", "0d", "0c", "0b", "0b", "0b", "0b", "0a", "1d", "1b", "1c", "1a", "1d", "1c", "1b", "1a", "1d", "1b", "1c", "1a", "1d", "1b", "1c", "1a", "2La", "2Lb", "2I", "2La", "2Lb", "2La", "2Lb", "2I", "2La", "2Lb", "3", "3", "3", "3", "4"]
		angles = [0, 0, 3, 2, 1, 0, 0, 1, 3, 1, 2, 0, 1, 2, 3, 0, 2, 2, 2, 2, 1, 1, 1, 1, 0, 0, 0, 0, 3, 3, 3, 3, 1, 1, 0, 2, 2, 0, 0, 1, 3, 3, 0, 1, 2, 3, 0]
		
		for (i=0; i<47; i++)
			if ((neighbourhood | masks[i]) == values[i]) {
				var r = "url(imgs/wall"+imageNames[i]+"-"+angles[i]+".png), url(imgs/empty.png)"
				if (stop)
					document.getElementsByClassName("cell")[y*mapSize+x].style.backgroundImage = r
				return r
			}
	}
	if (cell.type == 2)
		return "url(imgs/basic"+cell.owner+".png)"
	if (cell.type == 3)
		return "url(imgs/city"+cell.owner+".png)"
	if (cell.type == 4)
		return "url(imgs/tower"+cell.owner+".png)"
	if (cell.type == 5)
		return "url(imgs/lab"+cell.owner+".png)"
}

// Change the active tool
function setActiveTool(tool) {
	if (activeTool)
		document.getElementById(activeTool).style.borderColor = "transparent"
	activeTool = tool
	document.getElementById(tool).style.borderColor = "#900"
}

// Start with small map
window.addEventListener("load", function () {
	setMapSize(10)
	document.getElementById("emptyTool").onclick =
	document.getElementById("wallTool").onclick =
	document.getElementById("basicTool").onclick =
	document.getElementById("cityTool").onclick =
	document.getElementById("towerTool").onclick =
	document.getElementById("labTool").onclick = function (event) {
		setActiveTool(event.currentTarget.id)
	}
	setActiveTool("wallTool")
})

// Handle a click inside a cell
function cellOnClick(event) {
	var cell = event.currentTarget
	var type, owner, population, level
	var toolNames, ownerNames
	if (event.ctrlKey) {
		// Make a copy of the clicked cell
		toolNames = ["emptyTool", "wallTool", "basicTool", "cityTool", "towerTool", "labTool"]
		ownerNames = ["abandoned", "red", "green", "blue", "white"]
		cell = map[cell.dataset.x][cell.dataset.y]
		setActiveTool(toolNames[cell.type])
		if (cell.type > 1) {
			document.getElementById("owner").value = ownerNames[cell.owner]
			document.getElementById("population").value = cell.population
		}
		if (cell.type > 2) {
			document.getElementById("level").value = cell.level
		}
	} else {
		// Set the cell
		type = activeTool.substr(0, activeTool.length - 4)
		owner = getOwnerId()
		population = document.getElementById("population").value
		level = Number(document.getElementById("level").value)
		if (type == "empty" || type == "wall") {
			cell.innerHTML = ""
			setStars(cell, 0)
		} else {
			cell.innerHTML = population
			setStars(cell, type == "basic" ? 0 : level - 1)
		}
		map[cell.dataset.x][cell.dataset.y] = { type: getTypeId(type), owner: owner, population: population, level: level }
		cell.style.backgroundImage = cell2image(Number(cell.dataset.x), Number(cell.dataset.y))
	}
}

// Handle the mouse down
var dragging = false
function cellOnMouseDown(event) {
	var type = activeTool.substr(0, activeTool.length - 4)
	if (type == "empty" || type == "wall") {
		dragging = true
		window.addEventListener("mouseup", stopDragging)
		event.preventDefault()
	}
}

// Handle mouse move
function cellOnMouseMove(event) {
	if (dragging)
		cellOnClick(event)
}

// Clear draggin flag
function stopDragging() {
	dragging = false
	window.removeEventListener("mouseup", stopDragging)
}

// Get the owner id
function getOwnerId() {
	switch (document.getElementById("owner").value) {
		case "abandoned": return 0
		case "red": return 1
		case "green": return 2
		case "blue": return 3
		case "white": return 4
	}
}

// Get the type id from the type string
function getTypeId(type) {
	switch (type) {
		case "empty": return 0
		case "wall": return 1
		case "basic": return 2
		case "city": return 3
		case "tower": return 4
		case "lab": return 5
	}
}

// Update the number of stars in the given cell
function setStars(cell, num) {
	var before = cell.getElementsByClassName("star")
	var i = before.length, star
	while (i > num) {
		cell.removeChild(before[i-1])
		i--
	}
	while (i < num) {
		star = document.createElement("div")
		star.className = "star"
		star.style.left = (16*i)+"px"
		cell.appendChild(star)
		i++
	}
}

// Save the map to JSON format
function save() {
	var data = {}
	var players = [null, null, null, null]
	var x, y, cell, cellData, owner, nPlayers = 0, str
	data.size = mapSize
	data.mana = Number(document.getElementById("mana").value)
	data.cells = []
	for (y = 0; y < mapSize; y++) {
		for (x = 0; x < mapSize; x++) {
			cell = map[x][y]
			cellData = { x: x, y: mapSize - y - 1, type: cell.type }
			if (cell.type > 1) {
				owner = cell.owner
				if (owner == 0)
					cellData.owner = null
				else {
					if (players[owner - 1] === null)
						players[owner - 1] = nPlayers++
					cellData.owner = players[owner-1]
				}
				cellData.population = getPopulation(cell)
			}
			if (cell.type > 2)
				cellData.level = cell.level
			if (cell.type != 0)
				data.cells.push(cellData)
		}
	}
	data.players = nPlayers
	
	// Open the output file
	var blob = new Blob(["module.exports=" + JSON.stringify(data).replace(/"/g, "")], {type: "text/plain"})
	window.open(window.URL.createObjectURL(blob))
}

// Return the amount of population for a given cell object
function getPopulation(cell) {
    var max = getMaxPopulation(cell)
    switch (cell.population) {
        case "\u2205": return 0;
        case "\u00BC": return Math.round(max/4);
        case "\u00BD": return Math.round(max/2);
        case "\u00BE": return Math.round(3*max/4);
        case "1": return max;
    }
}

// Return the max population for the given cell object
function getMaxPopulation(cell) {
	var values = {
		1: [10, 10, 10, 10],
		2: [30, 45, 60, 75],
		3: [20, 30, 40, 50],
		4: [20, 30, 40, 50]
	}
	return values[cell.type][cell.level]
}
