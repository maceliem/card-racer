extends VBoxContainer

func _ready():
	Global.connect("toggle_network_setup", self, "_toggle_network_setup")

func _on_IpAdress_text_changed(new_text:String):
	Network.ipAddress = new_text


func _on_Host_pressed():
	Network.createServer()
	doBoth()


func _on_Join_pressed():
	Network.joinServer()
	doBoth()

func doBoth():
	var id = get_tree().get_network_unique_id()
	var main = get_parent().get_parent()
	get_parent().hide()
	main.playerCustomization[id] = main.ownCustomization
	main.get_node("gameInterface").visible = true
	main._saveGame()
	Global.emit_signal("instance_player", id)

func _toggle_network_setup(toggle):
	visible = toggle
