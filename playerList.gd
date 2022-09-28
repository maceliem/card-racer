extends VBoxContainer

export(Array, Texture) var readyIcon := []


func addPlayer(name: String, color: Color, icon: Texture, id: int):
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
	var font: Font = load("res://assets/Text/basicFont.tres")
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
	add_child(box)
	box.add_constant_override("separation", 16)
	box.name = str(id)
	pass


func removePlayer(id: int):
	var box = get_node(str(id))
	remove_child(box)
	box.queue_free()
