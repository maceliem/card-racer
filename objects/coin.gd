extends Area
tool

var type := "coin" setget updateCoin

var values := {
	"coin": 1,
	"ruby": 2,
}


func _on_coin_body_entered(body: Node):
	if body.name == "Road":
		return
	body.coins += values[type]
	body.get_node("UI/coinCounter/Label").text = str(body.coins)
	visible = false
	$Timer.start()
	if body.name == str(get_tree().get_network_unique_id()):
		Global.statistics[type[0].to_upper() + type.substr(1) + " collected:"] += 1
		Global._saveGame()


func _on_Timer_timeout():
	visible = true


func _ready():
	var coin = load("res://assets/Objects/" + type + ".glb").instance()
	coin.name = "coin"
	add_child(coin)
	if Engine.editor_hint:
		coin.scale = Vector3(30, 30, 30)
		coin.rotation_degrees.x = 90
	else:
		coin.scale = Vector3(10, 10, 10)
		coin.rotation_degrees.x = 0
		$AnimationPlayer.play("spin")


func updateCoin(name: String):
	remove_child(get_node("coin"))
	var coin = load("res://assets/Objects/" + name + ".glb").instance()
	coin.name = "coin"
	coin.scale = Vector3(10, 10, 10)
	coin.rotation_degrees.x = 0
	add_child(coin)
