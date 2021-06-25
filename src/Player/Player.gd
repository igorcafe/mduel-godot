extends KinematicBody2D
class_name Player

export var id := "p1"
export var move_speed := 70
export var jump_speed := 200
export var rope_speed := 70
export var facing_right := true
export var default_gravity := 10.0
export var player_texture: Texture

enum States { GROUND, AIR, ROPE }
var generic_state = States.ROPE
var gravity := default_gravity
var vel := Vector2.ZERO
var rope_position := Vector2.ZERO
var travel_to

# Input flags
# p = pressed, jp = just_pressed
var p_up := false
var jp_up := false
var p_down := false
var jp_down := false
var p_left := false
var p_right := false
var jp_item := false

# Other flags
var jumping := false
var can_move_x := true
var on_floor := false
var can_jump := false
var has_jumped := false
var being_dragged := false
var touching_rope := false

onready var anim_tree = $AnimationTree
onready var coll_shape = $CollisionShape2D
onready var state_machine = anim_tree["parameters/playback"]
onready var player_sprite = $PlayerSprite
onready var boots_sprite = $BootsSprite

func _ready():
	player_sprite.texture = player_texture
	flip_h(not facing_right)
	anim_tree.active = true

func _physics_process(_delta):
	p_up = Input.is_action_pressed(id + '_up')
	jp_up = Input.is_action_just_pressed(id + '_up')
	p_down = Input.is_action_pressed(id + '_down')
	jp_down = Input.is_action_just_pressed(id + '_down')
	p_left = Input.is_action_pressed(id + '_left')
	p_right = Input.is_action_pressed(id + '_right')
	jp_item = Input.is_action_just_pressed(id + '_item')
	on_floor = is_on_floor()

	match generic_state:
		States.GROUND:
			if not on_floor:
				generic_state = States.AIR
				return
			
			being_dragged = false
			travel_to = "idle"
			can_move_x = state() in [ "idle", "run" ]
			can_jump = can_move_x

			if can_move_x:
				vel.x = 0
				travel_to = "idle"
				if p_right:
					vel.x = +move_speed
					travel_to = "run"
					flip_h()
				elif p_left:
					vel.x = -move_speed
					travel_to = "run"
					flip_h()

			if touching_rope and not vel.x and (p_up or p_down):
				generic_state = States.ROPE
				travel_to = "rope_climbing"
			else:
				if jp_up and can_jump and not has_jumped:
					can_move_x = false
					has_jumped = true
					jump()
					generic_state = States.AIR
				elif jp_down and vel.x:
					can_move_x = false
					can_jump = false
					travel_to = "roll_forward"
				elif p_down and not vel.x:
					can_move_x = false
					can_jump = false
					travel_to = "duck"
			state_machine.travel(travel_to)

		States.AIR:
			if on_floor:
				has_jumped = false
				generic_state = States.GROUND
				state_machine.travel("idle")

			elif not being_dragged:
				if has_jumped and vel.y < 0:
					if vel.x:
						travel_to = "jump_running"
					else:
						travel_to = "jump_in_place"
				else:
					travel_to = "fall"
				state_machine.travel(travel_to)
	
		States.ROPE:
			vel.x = (int(p_right) - int(p_left)) * rope_speed
			if vel.x or not touching_rope:
				set_collision_mask_bit(Global.Layers.GROUND, true)
				set_collision_mask_bit(Global.Layers.ROPE_ENDS, false)
				gravity = default_gravity
				state_machine.travel("idle")
				generic_state = States.GROUND
			else:
				set_collision_mask_bit(Global.Layers.GROUND, false)
				set_collision_mask_bit(Global.Layers.ROPE_ENDS, true)
				global_position.x = rope_position.x
				gravity = 0
				vel.y = (int(p_down) - int(p_up)) * rope_speed
				if vel.y:
					travel_to = "rope_climbing"
				else:
					travel_to = "rope_idle"
				state_machine.travel(travel_to)
		
	vel.y += gravity
	vel = move_and_slide(vel, Vector2.UP)
	

func flip_h(value = null):
	if value == null:
		value = player_sprite.flip_h
		if (vel.x > 0 and player_sprite.flip_h) \
		or (vel.x < 0 and not player_sprite.flip_h):
			value = not player_sprite.flip_h
	player_sprite.flip_h = value
	boots_sprite.flip_h = value
	facing_right = not value
		

func jump(multi = 1):
	vel.y = -jump_speed * multi

func state():
	return state_machine.get_current_node()

func throw(right: bool, move_up := false):
	if right == facing_right:
		travel_to = "throwed_forward"
	else:
		travel_to = "throwed_backward"

	if right:
		vel.x = +move_speed
	else:
		vel.x = -move_speed
	if move_up:
		# vel.x /= 1.1
		vel.y = -jump_speed / 1.5
	
	being_dragged = true
	can_move_x = false
	vel = move_and_slide(vel)
	state_machine.travel(travel_to)
		
