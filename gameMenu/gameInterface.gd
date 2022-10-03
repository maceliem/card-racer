extends Control


func _on_begin_pressed():
	var keys: Array = $TabContainer/LevelSelect.votes.keys()
	var selectedLevel: String = $TabContainer/LevelSelect.votes[keys[randi() % len(keys)]]
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
