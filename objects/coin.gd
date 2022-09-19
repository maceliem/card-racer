extends Area
tool

var type := "ruby"

func _on_coin_body_entered(body:Node):
	if body.name == "Road": return
	body.coins += body.coinValue
	body.get_node("UI/coinCounter/Label").text = str(body.coins)
	visible = false
	$Timer.start()


func _on_Timer_timeout():
	visible = true

func _ready():
	var coin = load("res://assets/Objects/"+type+".glb").instance()
	coin.name = "coin"
	add_child(coin)
	if Engine.editor_hint:
		$coin.scale = Vector3(30,30,30)
		$coin.rotation_degrees.x = 90
	else:
		$coin.scale = Vector3(10,10,10)
		$coin.rotation_degrees.x = 0
		$AnimationPlayer.play("spin")
