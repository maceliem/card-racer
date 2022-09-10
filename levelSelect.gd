extends Control
export(Array, Texture) var worldImages := []
export(Array, Array, Texture) var levelImages := []
export(Array, Texture) var readyIcon := []

var worldButtons := ButtonGroup.new()
var levelButtons := ButtonGroup.new()

var votes := {}

func _ready():
	var worlds := list_files_in_directory("res://levels")
	for worldname in worlds:
		var world := Button.new()
		world.rect_min_size = Vector2(192, 192)
		world.name = worldname
		world.icon_align = 1
		world.set_button_group(worldButtons)
		world.connect("pressed", self, "_worldPressed")
		if len(worldImages) >= int(worldname) and worldImages[int(worldname)-1] != null: #check if world image has been made
			world.icon = worldImages[int(worldname)-1]
		else: #if not, we just display the name
			world.text = "world: " + worldname
		$GridContainer.add_child(world)
		
		var worldGrid := GridContainer.new()
		worldGrid.columns = 4
		worldGrid.visible = false
		worldGrid.name = "grid"
		worldGrid.rect_position = Vector2(0- world.rect_position.x, 262 - world.rect_position.y)
		worldGrid.rect_min_size = Vector2(1406, 456)
		
		var levels := list_files_in_directory("res://levels/" + worldname)
		for levelname in levels:
			var level = Button.new()
			level.rect_min_size = Vector2(128, 128)
			levelname = levelname.split(".")[0]
			level.name = worldname + "-" + levelname
			level.icon_align = 1
			if len(levelImages) >= int(levelname) and levelImages[int(worldname)-1][int(levelname)] != null:
				level.icon = levelImages[int(worldname)-1][int(levelname)]
			else:
				level.text = worldname + "-" + levelname
			level.set_button_group(levelButtons)
			level.connect("pressed", self, "_levelPressed")
			worldGrid.add_child(level)
		var worldBackground := ColorRect.new()
		worldBackground.rect_position = worldGrid.rect_position
		worldBackground.rect_min_size = worldGrid.rect_min_size
		worldBackground.name = "background"
		worldBackground.color = Color("#0f111a")
		worldBackground.visible = false
		world.add_child(worldBackground)
		world.add_child(worldGrid)

func _worldPressed():
	var worlds := worldButtons.get_buttons()
	var pressedWorld := worldButtons.get_pressed_button()
	for world in worlds:
		if world == pressedWorld: continue
		world.get_node("grid").visible = false
		world.get_node("background").visible = false
	var grid = pressedWorld.get_node("grid")	
	var background = pressedWorld.get_node("background")
	if grid.visible: grid.visible = false
	else: grid.visible = true	
	if background.visible: background.visible = false
	else: background.visible = true
	grid.rect_position = Vector2(0- pressedWorld.rect_position.x, 262 - pressedWorld.rect_position.y)
	background.rect_position = Vector2(0- pressedWorld.rect_position.x, 262 - pressedWorld.rect_position.y)

func _levelPressed():
	var levels := levelButtons.get_buttons()
	var pressedLevel := levelButtons.get_pressed_button()
	for level in levels:
		if level == pressedLevel: continue
		level.modulate = Color(1, 1, 1, 1)
	pressedLevel.modulate = Color(0.8, 0.8, 0.8, 1)
	_vote(pressedLevel.name)
	var allDone := true
	for id in get_tree().get_network_connected_peers():
		rpc_id(id, "_vote", pressedLevel.name)
		if $playerList.get_node(str(id) + "/readyTexture").texture == readyIcon[0]:
			allDone = false
	if get_tree().get_network_unique_id() == 1 and allDone:
		$begin.disabled = false
		

remote func _vote(levelName:String):
	var id = get_tree().get_rpc_sender_id()
	if id == 0: id = get_tree().get_network_unique_id()
	votes[id] = levelName
	$playerList.get_node(str(id) + "/readyTexture").texture = readyIcon[1]


func list_files_in_directory(path:String) -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()
	return files

func addPlayer(name:String, color:Color, icon:Texture, id:int):
	var box := HBoxContainer.new()
	box.alignment = 1
	var readyTexture = TextureRect.new()
	readyTexture.name = "readyTexture"
	readyTexture.texture = readyIcon[0]
	readyTexture.stretch_mode = 4
	var texture := TextureRect.new()
	texture.texture = icon
	texture.modulate = color
	var label := Label.new()
	label.text = name
	label.add_color_override("font_color", color)
	var font:Font = load("res://assets/basicFont.tres")
	label.add_font_override("font", font)
	var score = Label.new()
	score.text = str(0)
	score.add_color_override("font_color", color)
	score.add_font_override("font", font)
	score.name = "score"
	box.add_child(readyTexture)
	box.add_child(texture)
	box.add_child(label)
	box.add_child(score)
	$playerList.add_child(box)
	box.add_constant_override("separation", 16)
	box.name = str(id)
	pass

func removePlayer(id:int):
	var box = $playerList.get_node(str(id))
	remove_child(box)
	box.queue_free()

func _on_begin_pressed():
	var keys := votes.keys()
	var selectedLevel:String = votes[keys[randi() % len(keys)]]
	_begin(selectedLevel)
	for id in get_tree().get_network_connected_peers():
		rpc_id(id, "_begin", selectedLevel)

remote func _begin(levelName:String):
	var parts := levelName.split("-")
	var level:Track = load("res://levels/" + parts[0] + "/" + parts[1] + ".tscn").instance()
	level.name = "level"
	get_parent().add_child(level)
	for id in get_tree().get_network_connected_peers():
		get_parent().get_node(str(id))._start()
	var id = get_tree().get_network_unique_id()
	get_parent().get_node(str(id))._start()
	visible = false
