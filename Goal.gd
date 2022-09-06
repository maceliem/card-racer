extends Spatial



func _on_Area_body_entered(body:Node):
	if body.name == "Road": return
	print("Yaaay")
