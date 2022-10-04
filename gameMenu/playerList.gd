extends VBoxContainer

export(Array, Texture) var readyIcon := []


func addPlayer(name: String, color: Color, icon: Texture, id: int):
	var font: Font = load("res://assets/Text/basicFont.tres")

	#elements
	var box := HBoxContainer.new()
	box.name = str(id)
	box.alignment = 1
	box.add_constant_override("separation", 16)
	add_child(box)

	var readyTexture = TextureRect.new()
	readyTexture.name = "readyTexture"
	readyTexture.texture = readyIcon[0]
	readyTexture.stretch_mode = 4
	box.add_child(readyTexture)

	var profilePicture := TextureRect.new()
	profilePicture.texture = icon
	profilePicture.modulate = color
	box.add_child(profilePicture)

	var playerName := Label.new()
	playerName.text = name
	if id == Global.hostID:
		playerName.text += " (host)"
	playerName.add_color_override("font_color", color)
	playerName.add_font_override("font", font)
	box.add_child(playerName)

	var score = Label.new()
	score.text = str(0)
	score.add_color_override("font_color", color)
	score.add_font_override("font", font)
	score.name = "score"
	box.add_child(score)


func removePlayer(id: int):
	var box = get_node(str(id))
	remove_child(box)
	box.queue_free()
