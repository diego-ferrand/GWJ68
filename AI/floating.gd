extends CharacterBody3D
@onready var world = $"../.."
@onready var attack_raycast = $Rotateable/AttackRaycast
@onready var rotateable = $Rotateable
@onready var rate_of_fire = $RateOfFire
@onready var animation_player = $AnimationPlayer
@onready var ui_tick = $UITick
@onready var health_bar_3d = $HealthViewport/HealthBar3D
@onready var health_sprite = $HealthSprite

@onready var swing_hammer_sound = $Sounds/SwingHammer

@onready var sounds = {
	"hit_bow" : $Sounds/hit_bow,
	"dead_bow" : $Sounds/dead_bow,
	"hit_hammer" : $Sounds/hit_hammer,
	"dead_hammer" : $Sounds/dead_hammer,
	"hit_sword" : $Sounds/hit_sword,
	"dead_sword" : $Sounds/dead_sword
}


var max_health = 100
var curr_health = max_health
var attack_target
var gravity = -30.0
var speed = 3
var can_attack = true

var damage = 5

enum State {
	idle,
	walking,
	chasing,
	attacking,
	dead
}
var curr_state:State
var last_dir

signal DEAD

func _ready():
	curr_state = State.walking
	last_dir = -1 
	health_bar_3d.max_value = max_health
	health_bar_3d.value = curr_health
	if world.player:
		attack_target = world.player

func set_player_rotation():
	if attack_target:
		look_at(attack_target.global_position)
	else:
		attack_target = world.player
	 
func move_forward():
	return (attack_target.global_transform.origin - global_transform.origin).normalized()
		
func take_damage(damage, weapon_name):
	curr_health-=damage
	ui_tick.start()
	health_sprite.show()
	health_bar_3d.value = curr_health
	if curr_health <= 0:
		curr_state = State.dead
		animation_player.play("dead")
		attack_target = null
		sounds["dead_"+weapon_name].play()
		DEAD.emit()
	else:
		sounds["hit_"+weapon_name].play()

func _physics_process(delta):
	if curr_state == State.dead:
		return
	
	set_player_rotation()
	var direction
	
	if curr_state == State.walking:
		direction = move_forward()
	
	if curr_state == State.chasing and attack_target:
		var result = cast_ray_to_body(attack_target)
		if result.collider and result.collider == attack_target and global_position.distance_to(result.position) <= 2:
			curr_state = State.attacking
		else:
			direction = move_forward()
			
	
	if curr_state == State.attacking:
		var result = cast_ray_to_body(attack_target)
		if result and result.collider and result.collider == attack_target and global_position.distance_to(result.position) > 2:
			curr_state = State.chasing
		if can_attack:
			can_attack = false
			animation_player.play("attack")
			swing_hammer_sound.play()
			var hit = attack_raycast.get_collider()
			if hit and hit.has_method("take_damage"):
				hit.take_damage(damage, "player")
				
			rate_of_fire.start()
	
	if direction:
		velocity = direction * speed
	

	move_and_slide()
	last_dir = direction

func cast_ray_to_body(body):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, body.global_position)
	return space_state.intersect_ray(query)
	
func _on_vision_body_entered(body):
	if curr_state == State.dead:
		return
	if body.is_in_group("player"):
		var result = cast_ray_to_body(body)
		
		if result and result.collider == body:
			attack_target = body
			curr_state = State.chasing


func _on_vision_body_exited(body):
	if curr_state == State.dead:
		return
	if body==attack_target:
		attack_target = null
		curr_state = State.walking


func _on_rate_of_fire_timeout():
	if curr_state == State.dead:
		return
	can_attack = true
	animation_player.play("RESET")
	


func _on_ui_tick_timeout():
	health_sprite.hide()
