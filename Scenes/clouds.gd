extends MeshInstance3D

func _process(delta):
	material_override.set_uv1_offset(material_override.get_uv1_offset()+Vector3(0.0001,0,0))
