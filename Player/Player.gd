extends KinematicBody2D
class_name Player

export var id = "p1"
export var move_speed = 100
export var jump_speed = 200
export var rope_speed = 70
export var facing_right = true
export var default_gravity = 10
export var player_texture: Texture


var gravity = default_gravity
var vel = Vector2.ZERO
var keys = {}

# Input flags
# p = pressed, jp = just_pressed
var p_up := false
var jp_up := false
var p_down := false
var jp_down := false
var p_left := false
var p_right := false
var jp_item := false
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
		
	if is_on_floor():
		if state() in ["idle", "run"]:
			vel.x = move_speed * h_move
		state_machine.travel("idle")
		if vel.x and state() in ["idle", "run"]:
			run()
		if just_pressed(keys['up']):
			jump()
		if just_pressed(keys['item']):
			use_item()
		if pressed(keys['down']) and state() in ["duck", "idle"]:
			duck()
		elif just_pressed(keys['down']):
			state_machine.travel("roll_forward")
	
	elif state() in ["run", "idle"]:
		state_machine.travel("fall")
	
	elif state() in ["rope_idle", "rope_climbing"]:
		vel.x = move_speed * h_move
		rope()
		
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
		
func run():
	state_machine.travel("run")
	flip_h()
#	else:
#	$BootsSprite.flip_h = $Sprite.flip_h


func duck():
	vel.x = 0
	state_machine.travel("duck")


func set_coll_disabled(value):
	coll_shape.disabled = value
	
func get_coll_disabled():
	return coll_shape.disabled


func rope():
	set_collision_mask_bit(1, false)
	gravity = 0
	if vel.x:
		set_collision_mask_bit(1, true)
		gravity = default_gravity
		state_machine.travel("idle")
	elif pressed(keys['up']):
		vel.y = -rope_speed
		state_machine.travel("rope_climbing")
	elif pressed(keys['down']):
		vel.y = +rope_speed
		state_machine.travel("rope_climbing")
	else:
		vel.y = 0
		state_machine.travel("rope_idle")

func jump(multi = 1):
	if not state() in ["run", "idle"]:
		return
	if not vel.x:
		state_machine.travel("jump_in_place")
	else:
		state_machine.travel("jump_running")
	vel.y = -jump_speed * multi

func state():
	return state_machine.get_current_node()

func use_item():
	jump(1.35)

func roll_backwards():
	vel.x = -vel.x
	state_machine.travel("roll_backward")
	pass
	
func thrown_backwards():
	vel.x = -vel.x
	state_machine.travel("thrown_backward")

func _on_ScreenBoundaries_body_entered(body):
	thrown_backwards()

func drown():
	print("drown")

func pressed(key):
	return Input.is_action_pressed(key)
	
func just_pressed(key):
	return Input.is_action_just_pressed(key)
	
func strength(key):
	return Input.get_action_strength(key)
