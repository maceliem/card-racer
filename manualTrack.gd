extends Node
class_name Track

export(Array, Vector3) var startPositions
export(Texture) var preview

func _ready():
	$Road.translation.y = 0