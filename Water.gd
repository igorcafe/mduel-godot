extends Area2D

var splash_delay := 1.0
export (PackedScene) var splash_scene 

var offest := Vector2(0, 15)

func _on_Water_body_entered(body):
	print("entered")
	var player := body as Player
	var water_splash = splash_scene.instance()

	add_child(water_splash)
	water_splash.global_position = player.global_position - offest
	water_splash.play("splash")

	yield(get_tree().create_timer(2), "timeout")
	water_splash.queue_free()