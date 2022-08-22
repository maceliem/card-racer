tool
extends Node

export var update_map := false setget updateMap

func updateMap(_value):
	update_map = false
	var i = 0
	var oldVert1:Vector3
	var oldVert2:Vector3
	while $road.get_child_count() > 0:
		$road.remove_child($road.get_child(0))
	for point in $points.get_children():
		i += 1
		if i == 1: continue
		var lastPoint := $points.get_child(i-2)
		var roadPiece := MeshInstance.new()
		
		var tmpMesh = Mesh.new()
		var vertices = PoolVector3Array()
		var UVs = PoolVector2Array()
		var mat = SpatialMaterial.new()
		var color = Color(0.9, 0.1, 0.1)
		
		var a = lastPoint.translation #start pos
		var b = point.translation		#end pos
		var c = b - a 			#from old to new
		var d = a - b			#from new to old

		var angle = Vector2(a.x*2, a.z*2).angle_to(Vector2(b.x, b.z))
		if i != 2:
			if angle < 0: #til højre for
				vertices.push_back(a + Vector3(c.x, 0, c.z).cross(Vector3(0,1,0)).normalized()*10)
				vertices.push_back(oldVert1)
			elif angle > 0:
				vertices.push_back(oldVert2)
				vertices.push_back(a + Vector3(0,1,0).cross(Vector3(c.x, 0, c.z)).normalized()*10)
			else:
				vertices.push_back(a + Vector3(c.x, 0, c.z).cross(Vector3(0,1,0)).normalized()*10)
				vertices.push_back(a + Vector3(0,1,0).cross(Vector3(c.x, 0, c.z)).normalized()*10)

		else:
			vertices.push_back(a + Vector3(c.x, 0, c.z).cross(Vector3(0,1,0)).normalized()*10)
			vertices.push_back(a + Vector3(0,1,0).cross(Vector3(c.x, 0, c.z)).normalized()*10)
		vertices.push_back(b + Vector3(d.x, 0, d.z).cross(Vector3(0,1,0)).normalized()*10)
		vertices.push_back(b + Vector3(0,1,0).cross(Vector3(d.x, 0, d.z)).normalized()*10)
			
		
		UVs.push_back(Vector2(0,0))
		UVs.push_back(Vector2(0,1))
		UVs.push_back(Vector2(1,1))
		UVs.push_back(Vector2(1,0))

		mat.albedo_color = color

		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLE_FAN)
		st.set_material(mat)

		for v in vertices.size(): 
			st.add_color(color)
			st.add_uv(UVs[v])
			st.add_vertex(vertices[v])

		st.commit(tmpMesh)
		oldVert1 = b + Vector3(d.x, 0, d.z).cross(Vector3(0,1,0)).normalized()*10
		oldVert2 = b + Vector3(0,1,0).cross(Vector3(d.x, 0, d.z)).normalized()*10
		roadPiece.mesh = tmpMesh

		$road.add_child(roadPiece)
		$road.set_owner(get_tree().edited_scene_root)
		roadPiece.set_owner(get_tree().edited_scene_root)
		

func _ready():
	if Engine.editor_hint and get_node_or_null("points") == null:
		var points = Node.new()
		var road = StaticBody.new()
		points.name = "points"
		road.name = "road"
		var point1 = Position3D.new()
		var point2 = Position3D.new()
		points.add_child(point1)
		points.add_child(point2)
		add_child(points)
		add_child(road)
		
		points.set_owner(get_tree().edited_scene_root)
		point1.set_owner(get_tree().edited_scene_root)
		point2.set_owner(get_tree().edited_scene_root)
		road.set_owner(get_tree().edited_scene_root)

func _process(_delta):
	updateMap(false)
