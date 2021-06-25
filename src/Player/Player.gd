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

onready var ground_state = $States/Ground
onready var air_state = $States/Air
onready var rope_state = $States/Rope

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
			ground_state.process(self)
		States.AIR:
			air_state.process(self)
		States.ROPE:
			rope_state.process(self)
		
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
		vel.y = -jump_speed / 1.5
	
	being_dragged = true
	can_move_x = false
	vel = move_and_slide(vel)
	state_machine.travel(travel_to)
		

func _on_HurtBox_area_entered(body):
	var enemy := body.get_parent() as Player
	if enemy:
		if vel.x == -enemy.vel.x:
			if state() == enemy.state():
				throw(vel.x < 0, on_floor)
		
		elif vel.x == 0:
			if state() == 'duck' and enemy.state() == 'run':
				enemy.throw(enemy.vel.x > 0, enemy.on_floor)
			else:
				throw(enemy.vel.x > 0, on_floor)

				# wether the enemy is hiting this player with his back side
				var back_to_this_player = enemy.vel.x < 0 == enemy.facing_right

				if back_to_this_player:
					enemy.throw(enemy.vel.x < 0, enemy.on_floor)

				if enemy.generic_state != States.GROUND:
					enemy.throw(enemy.vel.x < 0, false)
					
