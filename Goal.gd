extends Spatial

var inGoal := 0


func _on_Area_body_entered(body: Node):
	if body.name == "Road":#Ignore road
		return
	body.laps += 1
	if body.is_network_master():
		Global.statistics["Laps finished:"] += 1
		Global._saveGame()
	body.get_node("UI/lapsCounter").text = (
		str(body.laps + 1)
		+ "\n /\n  "
		+ str(get_parent().maxLaps)
	)
	body.get_node("UI/lapsCounter").visible = true
	body.get_node("UI/lapsCounter/lapsTimer").start()
	if body.laps >= get_parent().maxLaps:#If done
		inGoal += 1
		
		body.finalPos = inGoal
		body.sleeping = true
		body.countdown = 3
		body.steering = 0
		body.get_node("back_left").engine_force = 0
		body.get_node("back_right").engine_force = 0

		if body.is_network_master():#If local player
			if inGoal == 1: #If first
				Global.statistics["1st places:"] += 1
			if inGoal == 2: #If second
				Global.statistics["2nd places:"] += 1
			if inGoal == 3: #If third
				Global.statistics["3rd places:"] += 1

		if inGoal == Global.main.playerCustomization.size():
			Global.main.finishRace()
