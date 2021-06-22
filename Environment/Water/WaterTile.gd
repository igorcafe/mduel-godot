extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var animation_delay
const ANIM_SPEED = .5
onready var anim_player = $AnimationPlayer
onready var timer = $Timer

func _ready():
	animation_delay = rand_range(0, 1)
	timer.start(animation_delay)

func _on_Timer_timeout():
	anim_player.play("shake", -1, ANIM_SPEED)
	pass


func _on_WaterTile_body_entered(body):
	var player = body as Player
	if player:
		if anim_player.current_animation != "splash":
			water_splash()
		player.drown()

func water_splash():
	anim_player.play("splash")
