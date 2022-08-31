extends VehicleBody

var maxRPM := 3000
var maxTorque := 800
var offroad := 0.5

func _ready():
	contact_monitor = true
	contacts_reported = 1000

func _physics_process(delta):
	steering = lerp(steering, Input.get_axis("right", "left") * 0.05, 10 * delta)
	var acceleration = Input.get_axis("break", "accelerate")
	var rpm = $back_left.get_rpm()
	var curTorque := maxTorque
	var curMaxRPM := maxRPM
	var onRoad:= false
	for obj in $Area.get_overlapping_bodies():
		if obj.name == "Road":
			onRoad = true
	if !onRoad: 
		curTorque *= offroad
		curMaxRPM *= offroad
	print(curTorque)
	$back_left.engine_force = acceleration * curTorque * (1 - rpm / curMaxRPM)
	rpm = $back_right.get_rpm()
	$back_right.engine_force = acceleration * curTorque * (1 - rpm / curMaxRPM)
