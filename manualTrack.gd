extends Node
class_name Track

export(Array, Vector3) var startPositions

func _ready():
	$Road.translation.y = 0