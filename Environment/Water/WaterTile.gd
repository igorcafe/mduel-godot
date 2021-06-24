extends Node2D

var animation_delay
const ANIM_SPEED = .5
onready var anim_player = $AnimationPlayer
onready var water_sprite = $WaterSprite

func _ready():
	animation_delay = rand_range(0, 1)
	yield(get_tree().create_timer(animation_delay), "timeout")
	water_sprite.play("default")
