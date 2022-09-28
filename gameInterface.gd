extends Control

var votes := {}


remote func _vote(levelName: String):
	var id = get_tree().get_rpc_sender_id()
	if id == 0:
		id = get_tree().get_network_unique_id()
	votes[id] = levelName
	$playerList.get_node(str(id) + "/readyTexture").texture = $playerList.readyIcon[1]


func _on_begin_pressed():
	var keys := votes.keys()
	var selectedLevel: String = votes[keys[randi() % len(keys)]]
	_begin(selectedLevel)
	for id in get_tree().get_network_connected_peers():
		rpc_id(id, "_begin", selectedLevel)


remote func _begin(levelName: String):
	var parts := levelName.split("-")
	var level: Track = load("res://levels/" + parts[0] + "/" + parts[1] + ".tscn").instance()
	level.name = "level"
	get_parent().add_child(level)
	for id in get_tree().get_network_connected_peers():
		get_parent().get_node(str(id))._start()
	var id = get_tree().get_network_unique_id()
	get_parent().get_node(str(id))._start()
	visible = false
