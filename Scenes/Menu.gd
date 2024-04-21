extends Control


func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")


func _on_how_to_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/HowToPlay.tscn")
