extends Spatial

var inGoal := 0

func _on_Area_body_entered(body:Node):
	if body.name == "Road": return
	body.laps += 1
	body.get_node("UI/lapsCounter").text = str(body.laps+1) + "\n /\n  " + str(get_parent().maxLaps)
	body.get_node("UI/lapsCounter").visible = true
	body.get_node("UI/lapsCounter/lapsTimer").start()
	if body.laps >= get_parent().maxLaps:
		inGoal += 1
		body.finalPos = inGoal
		body.sleeping = true
		body.countdown = 3
		body.steering = 0
		body.get_node("back_left").engine_force = 0
		body.get_node("back_right").engine_force = 0
		if inGoal == get_parent().get_parent().playerCustomization.size():
			get_parent().get_parent().finishRace()
