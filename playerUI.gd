extends Control

var mapPoints: PoolVector2Array = [] setget rescale

export var mapMargin := 40
export var mapColor := Color(1, 0, 0)
export var mapThickness := 10


func _draw():
	draw_polyline(mapPoints, mapColor, mapThickness, true)


func rescale(newValues):
	var low: Vector2
	var high: Vector2

	#define end points
	for point in newValues:
		if low.x == null or point.x < low.x:
			low.x = point.x
		if high.x == null or point.x > high.x:
			high.x = point.x
		if low.y == null or point.y < low.y:
			low.y = point.y
		if high.y == null or point.y > high.y:
			high.y = point.y

	#transform variables
	var scale = Vector2(
		($Map.rect_size.x - mapMargin * 2) / abs(high.x - low.x),
		($Map.rect_size.y - mapMargin * 2) / abs(high.y - low.y)
	)
	var translate = Vector2(
		($Map.rect_position.x + mapMargin) - low.x * scale.x,
		($Map.rect_position.y + mapMargin) - low.y * scale.y
	)
	var i = 0
	for point in newValues:
		point.x = scale.x * point.x + translate.x
		point.y = scale.y * point.y + translate.y
		newValues[i] = point
		i += 1
	mapPoints = newValues
	update()
