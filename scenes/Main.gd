extends Control

var height : int
var width : int
var matrix = []
var rules : Array = ["RL", "LLRR", "RLLR", "LRRRRRLLR", "LLRRRLRLRLLR", "RRLLLRLLLRRR", "LLRRRLRRRRR", "RLRRRLLLLLLR"]
var rule : String = ""
var started : bool = false
var x : int
var y : int
var dir : int = 1
var steps : int = 0

onready var OptionBox : OptionButton = $HBoxContainer/VBoxContainer/HBoxContainer_bot/OptionButton
onready var LineRandom : LineEdit = $HBoxContainer/VBoxContainer/HBoxContainer_bot/LineRandom
onready var SpeedBox : SpinBox = $HBoxContainer/VBoxContainer/HBoxContainer_top/SpinBox

func _ready():
	randomize()
	height = 140
	width = 200
	x = 50
	y = 40
	for x in range(width):
		matrix.append([])
		matrix[x] = []
		for y in range(height):
			matrix[x].append([])
			matrix[x][y] = 0
			$TileMap.set_cell(x, y, 0)
	$TileMap.set_cell(x, y, 16)
	for item in rules:
		OptionBox.add_item(item)
	OptionBox.add_separator()
	OptionBox.add_item("Random")
	OptionBox.add_item("Custom")
	LineRandom.text = "RL"

func step():
	if !started: return
	var cur_color = matrix[x][y]
	matrix[x][y] = (cur_color + 1) % rule.length()
	$TileMap.set_cell(x, y, matrix[x][y])
	
	if rule.substr(cur_color, 1) == "R":
		dir = (dir + 1) % 4 
	else:
		dir = (dir + 3) % 4

	match dir:
		0:
			x += 1
		1:
			y -= 1
		2:
			x -= 1
		3:
			y += 1
	
	if x == width - 1 or x == 0 or y == 0 or y == height - 1:
		started = false
	$TileMap.set_cell(x, y, 16)
	steps += 1

func _process(delta):
	var fps = str(Engine.get_frames_per_second())
	if started:
		OS.set_window_title("Langton's Ant - Running - Steps: " + str(steps) + " - " + fps + " fps")
	else:
		OS.set_window_title("Langton's Ant - Waiting - Steps: " + str(steps) + " - " + fps + " fps")

	if started:
		for i in range(SpeedBox.value):
			step()

func check_rule():
	if LineRandom.text == "": return false
	for i in LineRandom.text:
		if i != "R" and i != "L": return false
	return true

func _on_Button_start_pressed():
	if check_rule():
		rule = LineRandom.text
		started = !started
	else:
		_on_Button_reset_pressed()

func _on_Button_step_pressed():
	if check_rule():
		rule = LineRandom.text
		started = true
		step()
		started = false
	else:
		_on_Button_reset_pressed()

func _on_OptionButton_toggled(button_pressed):
	started = false
	steps = 0
	dir = 0
	x = width / 2
	y = height / 2
	for x in range(width):
		for y in range(height):
			matrix[x][y] = 0
			$TileMap.set_cell(x, y, 0)
	$TileMap.set_cell(x, y, 16)
	
	if OptionBox.text == "Random":
		LineRandom.visible = true
		LineRandom.text = ""
		var n = 2 + randi() % 14
		for i in range(n):
			if randi() % 2:
				LineRandom.text += "R"
			else:
				LineRandom.text += "L"
	elif OptionBox.text == "Custom":
		LineRandom.visible = true
		LineRandom.text = ""
		LineRandom.grab_focus()
	else:
		for x in range(width):
			for y in range(height):
				matrix[x][y] = 0
				$TileMap.set_cell(x, y, 0)
		LineRandom.text = OptionBox.text
		LineRandom.visible = false
		match OptionBox.selected:
			0:
				dir = 1
				x = 50
				y = 40
			1, 2, 3, 6, 7:
				dir = 0
				x = width / 2
				y = height / 2
			4:
				dir = 1
				x = 30
				y = height / 2
			5:
				dir = 2
				x = 30
				y = 115
		$TileMap.set_cell(x, y, 16)

func _on_Button_reset_pressed():
	started = false
	steps = 0
	x = 50
	y = 40
	dir = 1
	for x in range(width):
		for y in range(height):
			matrix[x][y] = 0
			$TileMap.set_cell(x, y, 0)
	$TileMap.set_cell(x, y, 16)
	OptionBox.select(0)
	LineRandom.visible = false
	LineRandom.text = "RL"
	
