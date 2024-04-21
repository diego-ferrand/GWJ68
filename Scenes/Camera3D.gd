extends Camera3D
@export var target:Node3D

func _process(delta):
	global_position.z = lerp(global_position.z, target.global_position.z, .01)
	global_position.y = lerp(global_position.y, target.global_position.y+2.5, .01)
	
