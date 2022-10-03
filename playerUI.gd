extends Control

var mapPoints: PoolVector2Array = [] setget rescale

export var mapMargin := 40
export var mapColor := Color(1, 0, 0)
export var mapThickness := 10
export var playerThickness := 7

var maplow: Vector2
var maphigh: Vector2
var mapscale: Vector2
var maptranslate: Vector2


func _draw():
	if mapPoints.empty():
		return
	draw_polyline(mapPoints, mapColor, mapThickness, true)
	for id in get_tree().get_network_connected_peers():
		var player: Player = Global.main.get_node(str(id))
		var point = (
			mapscale * Vector2(player.global_translation.x, player.global_translation.z)
			+ maptranslate
		)
		draw_circle(point, playerThickness, Global.main.playerCustomization[id].color)
	var point = (
		mapscale * Vector2(Global.player.global_translation.x, Global.player.global_translation.z)
		+ maptranslate
	)
	draw_circle(point, playerThickness + 4, Color(0, 0, 0, 1))
	draw_circle(point, playerThickness, Global.main.ownCustomization.color)


func rescale(newValues):
	#define end points
	for point in newValues:
		if maplow.x == NAN or point.x < maplow.x:
			maplow.x = point.x
		if maphigh.x == NAN or point.x > maphigh.x:
			maphigh.x = point.x
		if maplow.y == NAN or point.y < maplow.y:
			maplow.y = point.y
		if maphigh.y == NAN or point.y > maphigh.y:
			maphigh.y = point.y

	#transform variables
	mapscale = Vector2(
		($Map.rect_size.x - mapMargin * 2) / abs(maphigh.x - maplow.x),
		($Map.rect_size.y - mapMargin * 2) / abs(maphigh.y - maplow.y)
	)
	maptranslate = Vector2(
		($Map.rect_position.x + mapMargin) - maplow.x * mapscale.x,
		($Map.rect_position.y + mapMargin) - maplow.y * mapscale.y
	)
	var i = 0
	for point in newValues:
		point = mapscale * point + maptranslate
		newValues[i] = point
		i += 1
	mapPoints = newValues
	update()


func _on_countdown_timeout():
	get_parent().countdown -= 1
	if get_parent().countdown > 0:
		$countdown.start()
		$countdownText.text = str(get_parent().countdown)
	elif get_parent().countdown == 0:
		$countdown.start()
		$countdownText.text = "GO!!!"
		get_parent().get_node("NetworkTickRate").start()
	else:
		$countdownText.visible = false


func _on_lapsTimer_timeout():
	$lapsCounter.modulate.a -= 0.1
	if $lapsCounter.modulate.a < 0:
		$lapsCounter.modulate.a = 1
		$lapsCounter.visible = false
		$lapsCounter/lapsTimer.stop()
