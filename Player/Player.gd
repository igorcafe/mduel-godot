extends KinematicBody2D
class_name Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var move_speed = 100
export var jump_speed = 200
export var facing_right = true
export var gravity = 20
#export var animation_tree

var vel = Vector2.ZERO
onready var anim_tree = $AnimationTree
onready var state_machine = anim_tree["parameters/playback"]

func _ready():
#	animation_tree as AnimationTree
	anim_tree.active = true

func _physics_process(delta):
	var h_move = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if is_on_floor():
		if state() in ["idle", "run"]:
			vel.x = move_speed * h_move
		
		state_machine.travel("idle")
		
		if vel.x and state() in ["idle", "run"]:
			run()
			
		if Input.is_action_just_pressed("ui_up"):
			jump(1)
		
		if Input.is_action_just_pressed("ui_accept"):
			use_item()
				
		if Input.is_action_pressed("ui_down") and state() in ["duck", "idle"]:
			duck()
			
		elif Input.is_action_just_pressed("ui_down"):
			state_machine.travel("roll_forward")
	
	elif state() in ["run", "idle"]:
		state_machine.travel("fall")
		
	vel.y += gravity
	vel = move_and_slide(vel, Vector2.UP)
	
	
func run():
	state_machine.travel("run")
	$Sprite.flip_h = vel.x <= 0 or not facing_right
	$BootsSprite.flip_h = $Sprite.flip_h
#	if vel.x > 0:
#		$Sprite.flip_h = not facing_right
#	else:
#		$Sprite.flip_h = facing_right


func duck():
	vel.x = 0
	state_machine.travel("duck")


func jump(multi):
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
#	roll_backwards()

func drown():
	print("drown")
