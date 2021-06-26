tool 
extends Area2D

export var water_count := 20
export (PackedScene) var tile_scene
export (PackedScene) var splash_scene 

var splash_delay := 1.0
var offest := Vector2(0, 14)

func _ready():
	for i in range(water_count):
		var water = tile_scene.instance()
		add_child(water)
		water.position.x = i * 16


func _on_Water_body_entered(body):
	var player := body as Player
	var water_splash = splash_scene.instance()

	add_child(water_splash)
	water_splash.global_position = player.global_position - offest
	water_splash.play("splash")

	yield(get_tree().create_timer(2), "timeout")
	water_splash.queue_free()
