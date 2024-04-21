extends Node3D
@onready var spawns = $Spawns
@onready var enemy = $Enemy
@onready var timer = $Timer
@onready var player = $Player

const ai_scenes  = [
	{"scene": preload("res://AI/SlimeAI.tscn"), "air":false}, 
	{"scene": preload("res://AI/Simple.tscn"), "air":false}, 
	{"scene": preload("res://AI/floating.tscn"), "air":true}]
var points = 0

func _ready():
	player.GAMEOVER.connect(game_over)
	
func spawn_enemy():
	var spawn = spawns.get_children()[randi_range(0,spawns.get_child_count()-1)]
	var ai_type = ai_scenes[randi_range(0, len(ai_scenes)-1)]
	var inst = ai_type["scene"].instantiate()
	enemy.add_child(inst)
	inst.global_position = spawn.global_position
	if ai_type["air"]:
		inst.global_position.y += 3
	inst.DEAD.connect(add_point)

func game_over():
	Global.score = points
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func add_point():
	points+=1

func _on_timer_timeout():
	spawn_enemy()
