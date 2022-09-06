class_name Player
extends VehicleBody

var maxRPM := 3000
var maxTorque := 800
var offroad := 0.5

var rpm
var acceleration
var puppetPosition = Vector3()
var puppetRotation = Vector3()
var puppetRpm = 0.0
var puppetAcceleration = 0.0


func updateLook():
	#Wait until we have data
	if !get_parent().playerCustomization.has(int(name)):
		yield(get_tree(), "idle_frame")
		return updateLook()

	#get data
	var customVariables = get_parent().playerCustomization[int(name)]
	
	for child in $body.get_children():
		if child.material == null: #createMaterial
			child.material = SpatialMaterial.new()
		child.material.albedo_color = customVariables.color


export(NodePath) onready var camera = get_node(camera) as Camera
export(NodePath) onready var networckTickRate = get_node(networckTickRate) as Timer
export(NodePath) onready var movementTween = get_node(movementTween) as Tween

func _ready():
	contact_monitor = true
	contacts_reported = 1000
	updateLook()
	camera.current = is_network_master()


func _physics_process(delta):
	if is_network_master(): 
		steering = lerp(steering, Input.get_axis("right", "left") * 0.05, 10 * delta)
		acceleration = Input.get_axis("break", "accelerate")
		rpm = $back_left.get_rpm()
	else:
		global_transform.origin = puppetPosition
		global_rotation = puppetRotation
		rpm = puppetRpm
		acceleration = puppetAcceleration

	var curTorque := maxTorque
	var curMaxRPM := maxRPM
	var onRoad:= false
	for obj in $Area.get_overlapping_bodies():
		if obj.name == "Road":
			onRoad = true
	if !onRoad: 
		curTorque *= offroad
		curMaxRPM *= offroad
	$back_left.engine_force = acceleration * curTorque * (1 - rpm / curMaxRPM)
	rpm = $back_right.get_rpm()
	$back_right.engine_force = acceleration * curTorque * (1 - rpm / curMaxRPM)


puppet func update_state(p_position, p_rpm, p_rotation, p_acceleration):
		puppetPosition = p_position
		puppetRpm = p_rpm
		puppetRotation = p_rotation
		puppetAcceleration = p_acceleration

		#movementTween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis, p_position), 0.1)
		#movementTween.interpolate_property(self, "global_rotation", global_rotation, Transform(global_rotation, p_rotation), 0.1)
		movementTween.start()

func _on_NetworkTickRate_timeout():
	if is_network_master():
		rpc_unreliable("update_state", global_transform.origin, rpm, global_rotation, acceleration)
	else:
		networckTickRate.stop()
