class_name Player
extends VehicleBody
func get_class(): return "Player"

var maxRPM := 4000
var maxTorque := 2000
var offroad := 0.5
var workingBreaks := true
var handelingSpeed := 2
var handelingAmount := 0.02

var rpm := 0
var acceleration := 0
var puppetPosition := Vector3()
var puppetRotation := Vector3()
var puppetRpm := 0.0
var puppetAcceleration := 0.0

var startPos := 0
var countdownTime := 5
var position := 0
var trackDistance := 0
var chatting := false

var laps := -1
var finalPos: int

var coins := 0

var UI = load("res://player/playerUI.tscn").instance()


func updateLook():
	#Wait until we have data
	if !Global.main.playerCustomization.has(int(name)):
		yield(get_tree(), "idle_frame")
		return updateLook()
	#get data
	var customVariables = Global.main.playerCustomization[int(name)]
	$nametag.text = customVariables.name
	for child in $body.get_children():
		if child.material == null:  #createMaterial
			child.material = SpatialMaterial.new()
		child.material.albedo_color = customVariables.color


export(NodePath) onready var camera = get_node(camera) as Camera
export(NodePath) onready var networckTickRate = get_node(networckTickRate) as Timer
export(NodePath) onready var movementTween = get_node(movementTween) as Tween

func _start():
	if is_network_master():
		Global.player = self
	contact_monitor = true
	contacts_reported = 1000
	$Camera.current = false
	Global.main = get_parent()
	$back_left.engine_force = 0
	$back_right.engine_force = 0

	updateLook()
	camera.current = is_network_master()
	$nametag.visible = !is_network_master()
	var trackPosition: Position3D = Global.main.get_node("level").startPositions[Global.main.positions[int(
		name
	)]]
	global_transform.origin = trackPosition.translation
	global_rotation = trackPosition.rotation
	laps = -1
	add_child(UI)
	if is_network_master():
		UI.countdown = countdownTime
		UI._start()
	sleeping = false


func _physics_process(delta):
	if UI.countdown > 0:
		return
	if chatting:
		return
	if is_network_master():
		steering = lerp(
			steering, Input.get_axis("right", "left") * handelingAmount, handelingSpeed * delta
		)
		#if breaks arent working, we only apply acceleration, if car is still, or if input maches direction (+ & + || - & -)
		if (
			workingBreaks
			or abs($back_left.get_rpm()) <= 200
			or $back_left.get_rpm() * Input.get_axis("break", "accelerate") > 0
		):
			acceleration = Input.get_axis("break", "accelerate")
#		else:
#			acceleration = 0
		rpm = abs($back_left.get_rpm())
	else:
		global_transform.origin = puppetPosition
		global_rotation = puppetRotation
		rpm = puppetRpm
		acceleration = puppetAcceleration
		var curCamera = get_viewport().get_camera()
		if curCamera is Camera:
			var cameraPos = curCamera.global_transform.origin
			var between = Vector2(
				cameraPos.x - $nametag.global_transform.origin.x,
				cameraPos.z - $nametag.global_transform.origin.z
			)
			$nametag.rotation.y = 90 - between.angle() - self.rotation.y
			$nametag.pixel_size = between.length() / 2000
			if $nametag.pixel_size < 0.01:
				$nametag.pixel_size = 0.01
			if $nametag.pixel_size > 0.1:
				$nametag.pixel_size = 0.1
	UI.update()
	var curTorque := maxTorque
	var curMaxRPM := maxRPM
	var onRoad := false
	var offroadTypes := ["grass"]
	if $ground.get_collider() != null and !offroadTypes.has($ground.get_collider().name):
		onRoad = true
	if !onRoad:
		curTorque *= offroad
		curMaxRPM *= offroad
	$back_left.engine_force = acceleration * curTorque * (1 - rpm / curMaxRPM)
	rpm = abs($back_right.get_rpm())
	$back_right.engine_force = acceleration * curTorque * (1 - rpm / curMaxRPM)

	var tmp = calcDistranceTraveled()
	if tmp != -1:
		trackDistance = tmp
	position = 1
	for id in get_tree().get_network_connected_peers():
		var otherPlayer: Player = Global.main.get_node(str(id))
		if otherPlayer.laps > laps:
			position += 1
		elif otherPlayer.trackDistance > trackDistance:
			position += 1
	UI.get_node("PositionLabel").text = str(position)


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


func calcDistranceTraveled() -> int:
	if !Global.main.has_node("level"):
		return 0
	var curve: Curve3D = Global.main.get_node("level/Road").get_curve()

	return curve.get_baked_points().find(curve.get_closest_point(translation))

remote func send_message(text: String):
	if text == "":
		return
	var font: Font = load("res://assets/Text/chatFont.tres")
	var message := Label.new()
	message.add_font_override("font", font)
	message.autowrap = true
	var id
	if get_tree().get_rpc_sender_id() == 0:
		id = get_tree().get_network_unique_id()
	else:
		id = get_tree().get_rpc_sender_id()
	message.text = (
		Global.main.playerCustomization[id].name
		+ " - "
		+ text
	)
	get_parent().get_node(str(get_tree().get_network_unique_id()) + "/UI/Chat/chatLog").add_child(message)
