extends Control
const BUTTONS = { 
	"DOWN_GREEN": preload("res://Imports/Button_Down_green.png"),
	"DOWN_PINK": preload("res://Imports/Button_Down_pink.png"),
	"LEFT_GREEN" : preload("res://Imports/Button_Left_green.png"),
	"LEFT_PINK" : preload("res://Imports/Button_Left_pink.png"),
	"RIGHT_GREEN" : preload("res://Imports/Button_Right_green.png"),
	"RIGHT_PINK" : preload("res://Imports/Button_Right_pink.png"),
	"UP_GREEN" : preload("res://Imports/Button_Up_green.png"),
	"UP_PINK" : preload("res://Imports/Button_Up_pink.png"),
}
const X = preload("res://Imports/Button_X.png")
const SEQ_BTN = preload("res://Player/seq_btn.tscn")
const btn_size:int = 1024
var distance_scale:float = btn_size*.15625
@onready var sequence_container = $SequenceContainer

var curr_seq = []

func get_button(btn_name:String, correct:bool):
	return BUTTONS[btn_name+"_GREEN" if correct else btn_name+"_PINK"]

func clear_sequence_ui():
	curr_seq=[]
	for c in sequence_container.get_children():
		c.queue_free()

func display_sequence(seq:Array):
	clear_sequence_ui()
	var count = len(seq)
	for i in range(0,count):
		var btn_img = get_button(seq[i], false)
		var btn:TextureRect =SEQ_BTN.instantiate() 
		curr_seq.append(btn)
		sequence_container.add_child(btn)
		btn.texture = btn_img
		btn.size = Vector2(btn_size, btn_size)
		btn.position = Vector2(i*distance_scale, 0) 

func stop_sequence():
	clear_sequence_ui()
	

func update_sequence(btn, cur, correct):
	var new_texture
	if correct:
		new_texture = get_button(btn, correct)
	else:
		new_texture = X
	curr_seq[cur].texture = new_texture
