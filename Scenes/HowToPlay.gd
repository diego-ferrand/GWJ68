extends Control
@onready var video_stream_player = $VideoStreamPlayer
@onready var next = $Next
@onready var prev = $Prev
@onready var label = $Label

var curr_step = 1

func _on_next_pressed():
	if curr_step == 8:
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	curr_step+=1
	update_ui()
	
func _on_prev_pressed():
	curr_step-=1
	update_ui()
	
func update_ui():
	if curr_step == 8:
		next.text = "Finish"
		label.text = "Once you die, you will be presented with a game over screen and your score.
		Have Fun :)"
	elif curr_step == 7:
		next.text = "Next"
		label.text = "Your objective is to last as long as you can. 
		Deafeating endless waves of enemy"
	elif curr_step == 6:
		label.text = "Use WASD as directional input to match the presented sequence.
		Successfully forging an upgrade will permanently increase weapon damage."

	elif curr_step == 5:
		label.text = "Navigate the menu with W and S for up and down. 
		Use J to select the option and K to go back."
	elif curr_step == 4:
		label.text = "Press TAB to open the menu. 
		Here you can switch between weapons or even upgrade them."
	elif curr_step == 3:
		label.text = "Use J to attack"
	elif curr_step == 2:
		prev.show()
		next.text = "Next"
		label.text = "Use K to jump"
	elif curr_step == 1:
		label.text = "Use A and D to move left and right"
		prev.hide()
		

	video_stream_player.stream = load("res://Imports/Tutorial/"+str(curr_step)+".ogv")
	video_stream_player.play()
