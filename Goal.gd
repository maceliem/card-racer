extends Spatial

var inGoal := 0

func _on_Area_body_entered(body:Node):
	if body.name == "Road": return
	body.laps += 1
	if body.laps > get_parent().maxLaps:
		inGoal += 1
		body.finalPos = inGoal
		body.sleeping = true
		body.countdown = 3
		body.steering = 0
		body.get_node("back_left").engine_force = 0
		body.get_node("back_right").engine_force = 0
		if inGoal == get_parent().get_parent().playerCustomization.size():
			get_parent().get_parent().finishRace()
