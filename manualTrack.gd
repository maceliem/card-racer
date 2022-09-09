extends Node
class_name Track

var startPositions := []
export(Texture) var preview

func _ready():
	$Road.translation.y = 0
	for child in $startPositions.get_children():
		startPositions.push_back(child.translation)