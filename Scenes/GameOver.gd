extends Control
@onready var score = $Score

func _ready():
	score.text = str(Global.score)

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
