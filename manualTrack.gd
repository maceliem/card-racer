extends Node
class_name Track

var startPositions := []
export(Texture) var preview
export var maxLaps := 3

var bakedPoints2D
func _ready():
	$Road.translation.y = 0
	for child in $startPositions.get_children():
		startPositions.push_back(child)

	var i := 0
	for type in Global.main.coinChance.keys():
		if type == "coins":
			continue
		i += Global.main.coinChance[type]
	Global.main.coinChance.coins = 100 - i

	var pool := []

	for type in Global.main.coinChance.keys():
		for j in range(0, Global.main.coinChance[type]):
			pool.push_back(type)

	for grp in $coins.get_children():
		for coin in grp.get_children():
			coin.type = pool[randi() % len(pool)]
	
	bakedPoints2D = []
	var j := 0
	for point in $Road.curve.get_baked_points():
		if j % 10 == 0:
			bakedPoints2D.push_back(Vector2(point.x, point.z))
			j+= 1
		else:
			j+= 1
	Global.player.get_node("UI").mapPoints = bakedPoints2D
