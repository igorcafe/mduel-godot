extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var animation_delay
const ANIM_SPEED = .5
onready var anim_player = $AnimationPlayer
onready var timer = $Timer
onready var water_sprite = $WaterSprite
onready var splash_sprite = $SplashSprite

func _ready():
	animation_delay = rand_range(0, 1)
	yield(get_tree().create_timer(animation_delay), "timeout")
	water_sprite.play("default")
#	anim_player.play("shake", -1, ANIM_SPEED)
func _on_Timer_timeout():
	pass


func _on_WaterTile_body_entered(body):
	var player = body as Player
	if player:
		splash_sprite.play("splash")
