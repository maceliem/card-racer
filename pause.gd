extends Control

func _input(event:InputEvent):
	if event.is_action_pressed("pause"):
		visible = !visible



func _on_Continue_pressed():
	visible = false


func _on_Settings_pressed():
	pass # Replace with function body.


func _on_Quit_pressed():
	if Network.client != null:
		Network.client.close_connection()
		get_tree().quit()
	elif Network.server != null:
		$quitWarning.visible = true
	else:
		get_tree().quit()
	

func _on_quitFR_pressed():
	for id in get_tree().get_network_connected_peers():
		Network.server.disconnect_peer(id)
	Network.server.close_connection()
	get_tree().quit()


func _on_noQuit_pressed():
	$quitWarning.visible = false
