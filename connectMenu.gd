extends Control

func _ready():
	Global.connect("toggle_network_setup", self, "_toggle_network_setup")

func _on_IpAdress_text_changed(new_text:String):
	Network.ipAddress = new_text


func _on_Host_pressed():
	Network.createServer()
	hide()

	Global.emit_signal("instance_player", get_tree().get_network_unique_id())


func _on_Join_pressed():
	Network.joinServer()
	hide()
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())

func _toggle_network_setup(toggle):
	visible = toggle