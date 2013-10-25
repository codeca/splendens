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
			div.className = obj2class(map[x][y])
			div.onclick = cellOnClick
			div.onmousedown = cellOnMouseDown
			div.onmousemove = cellOnMouseMove
			div.dataset.x = x
			div.dataset.y = y
			if (map[x][y].type > 1)
				div.innerHTML = map[x][y].population
			if (map[x][y].type > 2)
				setStars(div, map[x][y].level-1)
			mapDiv.appendChild(div)
		}
	}
	mapSize = size
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
			cell.className = "cell-" + type
			cell.innerHTML = ""
			setStars(cell, 0)
		} else {
			cell.className = "cell-" + type + owner
			cell.innerHTML = population
			setStars(cell, type == "basic" ? 0 : level - 1)
		}
		map[cell.dataset.x][cell.dataset.y] = { type: getTypeId(type), owner: owner, population: population, level: level }
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

// Return the right class name for the given cell object
function obj2class(cell) {
	switch (cell.type) {
		case 0: return "cell-empty"
		case 1: return "cell-wall"
		case 2: return "cell-basic" + cell.owner
		case 3: return "cell-city" + cell.owner
		case 4: return "cell-tower" + cell.owner
		case 5: return "cell-lab" + cell.owner
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
