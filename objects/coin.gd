extends Area
tool


func _on_coin_body_entered(body:Node):
	if body.name == "Road": return
	body.coins += body.coinValue
	body.get_node("UI/coinCounter/Label").text = str(body.coins)
	visible = false
	$Timer.start()


func _on_Timer_timeout():
	visible = true

func _ready():
	if Engine.editor_hint:
		$coin.scale = Vector3(30,30,30)
		$coin.rotation_degrees.x = 90
	else:
		$coin.scale = Vector3(10,10,10)
		$coin.rotation_degrees.x = 0
		$AnimationPlayer.play("spin")
