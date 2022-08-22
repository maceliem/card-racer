extends VehicleBody

var maxRPM := 3000
var maxTorque := 400

func _physics_process(delta):
    steering = lerp(steering, Input.get_axis("right", "left") * 0.05, 10 * delta)
    var acceleration = Input.get_axis("break", "accelerate")
    var rpm = $back_left.get_rpm()
    $back_left.engine_force = acceleration * maxTorque * (1 - rpm / maxRPM)
    rpm = $back_right.get_rpm()
    $back_right.engine_force = acceleration * maxTorque * (1 - rpm / maxRPM)