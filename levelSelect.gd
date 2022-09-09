extends Control
export(Array, Texture) var worldImages := []
export(Array, Array, Texture) var levelImages := []

var worldButtons := ButtonGroup.new()
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
			world.text = worldname
		$GridContainer.add_child(world)
		
		var worldGrid := GridContainer.new()
		worldGrid.columns = 4
		worldGrid.visible = false
		worldGrid.name = "grid"
		worldGrid.rect_position = Vector2(0- world.rect_position.x, 262 - world.rect_position.y)
		worldGrid.rect_min_size = Vector2(1656, 456)
		
		var levels := list_files_in_directory("res://levels/" + worldname)
		for levelname in levels:
			var level = Button.new()
			level.rect_min_size = Vector2(128, 128)
			level.name = levelname
			level.icon_align = 1
			if len(levelImages) >= int(levelname) and levelImages[int(worldname)-1][int(levelname)] != null:
				level.icon = levelImages[int(worldname)-1][int(levelname)]
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
		world.get_node("grid").visible = false
		world.get_node("background").visible = false
	var grid = pressedWorld.get_node("grid")	
	var background = pressedWorld.get_node("background")
	grid.visible = true	
	background.visible = true
	grid.rect_position = Vector2(0- pressedWorld.rect_position.x, 262 - pressedWorld.rect_position.y)
	background.rect_position = Vector2(0- pressedWorld.rect_position.x, 262 - pressedWorld.rect_position.y)
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
