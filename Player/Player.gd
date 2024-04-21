extends CharacterBody3D
@onready var animation_player = $AnimationPlayer
@onready var sequence_timer = $SequenceTimer
@onready var attack_rate = $AttackRate
@onready var health_bar_3d = $HealthViewport/HealthBar3D
@onready var ui_tick = $UITick
@onready var attack_check = $Armature/attack_check
@onready var attack_raycast = $Armature/attack_check/AttackRaycast
@onready var key_event = $Key_event/key_event
@onready var health_sprite = $HealthSprite
@onready var char = $Armature
@onready var ui = $UI
@onready var hurt_audio = $Node/hurt
@onready var wrong_audio = $Key_event/wrong
@onready var correct_audio = $Key_event/correct
@onready var anvil = $Armature/Anvil
@onready var hammer = $Armature/Skeleton3D/weapon/hammer

@onready var sounds = {
	"swing_hammer" : $Node/SwingHammer,
	"swing_sword" : $Node/SwingSword,
	"swing_bow" : $Node/SwingBow
}

@onready var weapons = [
	{"name": "hammer", "range": 2.5, "rate": 1, "dmg": 50, "ref": $Armature/Skeleton3D/weapon/hammer },
	{"name": "sword", "range": 3, "rate": .4, "dmg": 30, "ref": $Armature/Skeleton3D/weapon/sword},
	{"name": "bow", "range": 14.1, "rate": 2, "dmg": 10, "ref": $Armature/Skeleton3D/weapon/Bow}
]

@onready var curr_weapon = weapons[0]

var weapon_combos:Array = [["DOWN", "LEFT", "RIGHT"], ["DOWN", "DOWN", "RIGHT"], ["UP", "LEFT", "UP"], ["RIGHT", "RIGHT", "RIGHT"]]

var max_health = 100
var curr_health = max_health

var speed = 10.0
var jump_speed = 18.0
var gravity = -30.0

var is_key_squence = false
var in_ui = false

var keys = []

var curr_combo = 0
var curr_seq_iter = 0
var can_attack = true

signal GAMEOVER
func _ready():
	health_bar_3d.max_value = max_health
	health_bar_3d.value = curr_health
	update_weapon_range()
	curr_weapon["ref"].show()
func update_weapon_range():
	for child in attack_check.get_children():
		child.target_position = Vector3(0,0,-curr_weapon["range"])
	
func start_key_sequence():
	curr_combo = randi_range(0, len(weapon_combos)-1)
	animation_player.play("anvil")
	health_sprite.hide()
	is_key_squence = true
	key_event.display_sequence(weapon_combos[curr_combo])
	key_event.visible=true
	sequence_timer.start()

func stop_sequence_input():
	animation_player.play("RESET")
	is_key_squence = false
	sequence_timer.stop()
	key_event.stop_sequence()
	key_event.visible=false
	keys = []
	curr_seq_iter = 0

func take_damage(damage, weapon):
	curr_health-=damage
	health_sprite.show()
	health_bar_3d.value = curr_health
	if curr_health <=0:
		GAMEOVER.emit()
		return
	else:
		hurt_audio.play()
	
func handle_key_sequence(up_down, left_right):
	var key
	var correct
	if up_down:
		key = "UP" if Input.is_action_just_pressed("move_up") else "DOWN"
	if left_right:
		key = "RIGHT" if Input.is_action_just_pressed("move_right") else "LEFT"
	correct = weapon_combos[curr_combo][curr_seq_iter] == key
	key_event.update_sequence(key, curr_seq_iter, correct)
	if correct:
		curr_seq_iter += 1
		correct_audio.play()
	else:
		wrong_audio.play()
		curr_seq_iter = 0
	if curr_seq_iter >= len(weapon_combos[curr_combo]):
		curr_weapon["dmg"]+=5
		curr_seq_iter = 0

func get_raycast_collider():
	for child in attack_check.get_children():
		var hit = child.get_collider()
		if hit and hit != self and hit.has_method("take_damage"):
			return hit
	return null

func attack():
	can_attack = false
	if curr_weapon["name"] == "bow":
		animation_player.play("attack_bow")
	else:
		animation_player.play("Slash")
	#animation_player.play("attack_"+curr_weapon["name"])
	attack_rate.wait_time = curr_weapon["rate"]
	attack_rate.start()
	var hit = get_raycast_collider()
	sounds["swing_"+curr_weapon["name"]].play()
	if hit:
		hit.take_damage(curr_weapon["dmg"], curr_weapon["name"])

func _physics_process(delta):
	var direction = 0
	var up_down = Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down")
	var left_right = Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right")
	var is_attacking = Input.is_action_just_pressed("attack")
	
	if is_on_floor() and Input.is_action_just_pressed("jump") and !in_ui and !is_key_squence:
		animation_player.play("Jump")
		velocity.y = jump_speed
	
	elif not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
	
	if is_key_squence and Input.is_action_just_pressed("open_actions"):
		stop_sequence_input()
	elif Input.is_action_just_pressed("open_actions"):
		show_ui()
	elif is_key_squence and (up_down or left_right):
		handle_key_sequence(up_down, left_right)
	elif in_ui and (up_down or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("jump")):
		if Input.is_action_just_pressed("move_up"):
			ui.prev_option()
		elif Input.is_action_just_pressed("move_down"):
			ui.next_option()
		elif Input.is_action_just_pressed("attack"):
			ui.next_state()
		elif Input.is_action_just_pressed("jump"):
			ui.prev_state()
	elif !is_key_squence and !in_ui:
		if Input.is_action_pressed("move_right"):
			direction -= 1.0
			char.rotation.y = 0
		if Input.is_action_pressed("move_left"):
			direction += 1.0
			char.rotation.y = deg_to_rad(180)
		if Input.is_action_just_pressed("attack") and can_attack:
			attack()
	
	if (not animation_player.is_playing() or animation_player.current_animation == "Idle") and direction != 0:
		animation_player.play("Run")
	elif (not animation_player.is_playing() or animation_player.current_animation == "Run") and is_on_floor() and direction == 0:
		animation_player.play("Idle")
	
	velocity.z = direction * speed
	
	move_and_slide()
	curr_weapon["ref"].show()


func _on_timer_timeout():
	stop_sequence_input()
	
func enable_bit(mask: int, index: int) -> int:
	return mask | (1 << index)

func disable_bit(mask: int, index: int) -> int:
	return mask & ~(1 << index)

func _on_attack_rate_timeout():
	can_attack = true
	


func _on_ui_tick_timeout():
	health_bar_3d.hide()


func _on_platform_collision_body_entered(body):
	if body.is_in_group("one_way"):
		body.collision_layer = disable_bit(body.collision_layer, 0)


func _on_platform_collision_body_exited(body):
	if body.is_in_group("one_way"):
		body.collision_layer = enable_bit(body.collision_layer, 0)



func _on_ui_upgrade(weapon):
	exit_ui()
	_on_ui_equip(weapon)
	start_key_sequence()
	print("Upgrading: "+ str(weapon))


func _on_ui_equip(weapon):
	exit_ui()
	curr_weapon["ref"].hide()
	curr_weapon = weapons[weapon]
	curr_weapon["ref"].show()
	update_weapon_range()

	

func _on_ui_cancel():
	exit_ui()
	
func exit_ui():
	ui.hide()
	in_ui = false

func show_ui():
	ui.show()
	in_ui = true
