extends Node
class_name Main

var player := preload("res://Player.tscn")
var pauseMenu := preload("res://pause.tscn")
var feedbackMenu := preload("res://Feedback.tscn")

export(Texture) var icone

var ownCustomization := {"name": "Bob", "color": Color(0.3, 0.3, 0.3, 1)}

var positions := {1: 0}
var playerCustomization := {}

var coinChance := {"coin": 100}


func _init():
	Global.main = self


func _ready():
	_loadGame()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

	Global.connect("instance_player", self, "_instance_player")

	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup", false)


func _instance_player(id):
	var player_instance: Player = player.instance()
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	add_child(player_instance)
	while !playerCustomization.has(id):
		yield(get_tree(), "idle_frame")
	var customs: Dictionary = playerCustomization[id]
	var labelname: String = customs.name
	if id == 1:
		labelname += " (host)"
	$gameInterface/playerList.addPlayer(labelname, customs.color, icone, id)


func _player_connected(id):
	print("Player " + str(id) + " has connected")

	#only for the host
	if get_tree().get_network_unique_id() == 1:
		#give other players their positions and save it self
		var pos = len(get_tree().get_network_connected_peers())
		rpc_id(id, "givePlayerPos", [id, pos])
		positions[id] = pos
	rpc_id(id, "register_player", ownCustomization)
	_instance_player(id)


func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")

	if has_node(str(id)):
		get_node(str(id)).queue_free()
		$gameInterface/playerList.removePlayer(id)
		playerCustomization.erase(id)
		positions.erase(id)


func _on_LineEdit_text_changed(new_text: String):
	if new_text == "":
		ownCustomization.name = "Bob"
	else:
		ownCustomization.name = new_text


func _on_ColorPickerButton_color_changed(color: Color):
	ownCustomization.color = color


remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	playerCustomization[id] = info


remote func givePlayerPos(info):
	positions[info[0]] = info[1]


var saveFile = "user://cardRacerCustomization.save"


func _saveGame():
	var saveData := ownCustomization
	var file = File.new()
	file.open(saveFile, File.WRITE)
	file.store_var(saveData)
	file.close()


func _loadGame():
	var saveData
	var file = File.new()
	if file.file_exists(saveFile):
		file.open(saveFile, File.READ)
		saveData = file.get_var()
		file.close()

		for key in saveData.keys():
			if key == "pos":
				continue
			ownCustomization[key] = saveData[key]

		$gameElements/Customize/Label/ColorPickerButton.color = ownCustomization.color
		$gameElements/Customize/LineEdit.text = ownCustomization.name


func finishRace():
	$gameInterface.visible = true
	$gameInterface/begin.disabled = true
	for world in $gameInterface/TabContainer/LevelSelect.worldButtons.get_buttons():
		world.get_node("grid").visible = false
		world.get_node("background").visible = false
	for id in playerCustomization.keys():
		$gameInterface/playerList.get_node(str(id) + "/readyTexture").texture = $gameInterface/playerList.readyIcon[0]
		var player_instance: Player = get_node(str(id))
		var score := int($gameInterface/playerList.get_node(str(id) + "/score").text)
		if playerCustomization.size() == 1:
			score += 1
		else:
			score += playerCustomization.size() - player_instance.finalPos
		$gameInterface/playerList.get_node(str(id) + "/score").text = str(score)
	var ownPlayer: Player = get_node(str(get_tree().get_network_unique_id()))
	ownPlayer.camera.current = false
	ownPlayer.get_node("UI").visible = false
	$gameInterface/TabContainer/Shop/coinCounter/Label.text = str(ownPlayer.coins)
	$Camera2D.current = true
	get_node("level").queue_free()


func _on_FeedbackButton_pressed():
	var feedbackInstance: Control = feedbackMenu.instance()
	feedbackInstance.name = "feedbackMenu"
	add_child(feedbackInstance)


func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		if has_node("pauseMenu"):
			get_node("pauseMenu").queue_free()
		else:
			var pauseInstance: Control = pauseMenu.instance()
			pauseInstance.name = "pauseMenu"
			add_child(pauseInstance)
