extends Node2D

var animation_delay
const ANIM_SPEED = 0.5
onready var water_sprite = $WaterSprite

func _ready():
	animation_delay = rand_range(0, 1)
	yield(get_tree().create_timer(animation_delay), "timeout")
	water_sprite.play("default")
