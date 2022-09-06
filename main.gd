extends Node

var player = preload("res://Player.tscn")

var ownCustomization := {
	"name":"Bob",
	"color": Color(0.3,0.3,0.3,1)
}

var playerCustomization = {}
func _ready():
	_loadGame()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

	Global.connect("instance_player", self, "_instance_player")

	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup", false)
	
func _instance_player(id):
	var player_instance:Player = player.instance()
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	add_child(player_instance)
	print("list ", playerCustomization)
	player_instance.global_transform.origin = $level.startPositions[0]
	

func _player_connected(id):
	print("Player " + str(id) + " has connected")
	rpc_id(id, "register_player", ownCustomization)
	_instance_player(id)

func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")

	if has_node(str(id)):
		get_node(str(id)).queue_free()

func _on_LineEdit_text_changed(new_text:String):
	if new_text == "":
		ownCustomization.name = "Bob"
	else: 
		ownCustomization.name = new_text

func _on_ColorPickerButton_color_changed(color:Color):
		ownCustomization.color = color

remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	print("ged", id)
	print(info)
	# Store the info
	playerCustomization[id] = info

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
			ownCustomization[key] = saveData[key]

		$HBoxContainer/Customize/Label/ColorPickerButton.color = ownCustomization.color
		$HBoxContainer/Customize/LineEdit.text = ownCustomization.name
