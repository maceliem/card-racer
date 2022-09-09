class_name Player
extends VehicleBody

var main:Node

var maxRPM := 3000
var maxTorque := 800
var offroad := 0.5

var rpm
var acceleration
var puppetPosition := Vector3()
var puppetRotation := Vector3()
var puppetRpm := 0.0
var puppetAcceleration := 0.0

var startPos := 0
var countdown := 3

func updateLook():
	#Wait until we have data
	if !main.playerCustomization.has(int(name)):
		yield(get_tree(), "idle_frame")
		return updateLook()

	#get data
	var customVariables = main.playerCustomization[int(name)]
	$nametag.text = customVariables.name
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
	$Camera.current = false

func _start():
	main = get_parent()
	updateLook()
	camera.current = is_network_master()
	$nametag.visible = !is_network_master()
	global_transform.origin = main.get_node("level").startPositions[main.positions[int(name)]]
	$countdown/countdownText.translation = Vector3(translation.x, translation.y +6, translation.z - 6)
	$countdown/countdownText.font.size = 75
	$countdown/countdownText.visible = is_network_master()
	$NetworkTickRate.start()
	$countdown.start()
	sleeping = false 


func _physics_process(delta):
	if countdown>0: 
		$countdown/countdownText.font.size += 1
		return
	if is_network_master(): 
		steering = lerp(steering, Input.get_axis("right", "left") * 0.05, 10 * delta)
		acceleration = Input.get_axis("break", "accelerate")
		rpm = $back_left.get_rpm()
	else:
		global_transform.origin = puppetPosition
		global_rotation = puppetRotation
		rpm = puppetRpm
		acceleration = puppetAcceleration
		var cameraPos = get_viewport().get_camera().global_transform.origin
		var between = Vector2(cameraPos.x - $nametag.global_transform.origin.x, cameraPos.z - $nametag.global_transform.origin.z)
		$nametag.rotation.y = 90 - between.angle() - self.rotation.y
		$nametag.pixel_size = between.length() / 2000
		if $nametag.pixel_size < 0.01: $nametag.pixel_size = 0.01
		if $nametag.pixel_size > 0.1: $nametag.pixel_size = 0.1

	
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


func _on_countdown_timeout():
	countdown -= 1
	if countdown > 0:
		$countdown.start()
		$countdown/countdownText.text = str(countdown)
		$countdown/countdownText.font.size = 75
	elif countdown == 0:
		$countdown.start()
		$countdown/countdownText.text = "GO!!!"
		$countdown/countdownText.font.size = 75
	else: $countdown/countdownText.visible = false

