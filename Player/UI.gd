extends Control
@onready var weapon_select = $WeaponSelect
@onready var action_select = $ActionSelect
@onready var action_select_bg = $ActionSelectBG
@onready var click_2 = $Click2
@onready var click_1 = $Click1

enum WEAPONS {
	HAMMER,
	SWORD,
	BOW,
	CANCEL
}
enum ACTIONS {
	EQUIP,
	UPGRADE,
	CANCEL
}

enum STATE {
	ONE,
	TWO
}
@onready var current_selection_weapon = WEAPONS.HAMMER
@onready var current_selection_action = ACTIONS.EQUIP

signal UPGRADE
signal EQUIP
signal CANCEL

var curr_state: STATE = STATE.ONE

func update_weapon_selection(mod):
	current_selection_weapon += mod
	current_selection_weapon = clamp(current_selection_weapon, 0, len(WEAPONS))
	weapon_select.position.y = -current_selection_weapon*30

func next_weapon():
	update_weapon_selection(1)

func prev_weapon():
	update_weapon_selection(-1)

func update_action_selection(mod):
	current_selection_action += mod
	current_selection_action = clamp(current_selection_action, 0, len(ACTIONS))
	action_select.position.y = -current_selection_action*30

func next_selection():
	update_action_selection(1)

func prev_selection():
	update_action_selection(-1)

func next_option():
	if curr_state == STATE.ONE:
		next_weapon()
	else:
		next_selection()
		
func prev_option():
	if curr_state == STATE.ONE:
		prev_weapon()
	else:
		prev_selection()

func update_state_change():
	if curr_state == STATE.ONE:
		action_select.hide()
		action_select_bg.hide()
	else:
		action_select.show()
		action_select_bg.show()

func next_state():
	click_1.play()	
	if curr_state == STATE.ONE and current_selection_weapon == WEAPONS.CANCEL:
		current_selection_weapon = WEAPONS.HAMMER
		update_weapon_selection(-len(WEAPONS)) # set to default aka equip
		CANCEL.emit()
	elif curr_state == STATE.ONE:
		curr_state = STATE.TWO
	else:
		if current_selection_action == ACTIONS.EQUIP:
			prev_state()
			EQUIP.emit(current_selection_weapon)
		elif current_selection_action == ACTIONS.UPGRADE:
			prev_state()
			UPGRADE.emit(current_selection_weapon)
			current_selection_action = ACTIONS.EQUIP
		else: # cancel is selected for weapn action
			prev_state()
	update_state_change()

func prev_state():
	if !click_1.playing:
		click_2.play()
	if curr_state == STATE.ONE:
		CANCEL.emit()
		return
		
	curr_state = STATE.ONE

	update_action_selection(-len(ACTIONS)) # set to default aka equip
	update_state_change()
	
