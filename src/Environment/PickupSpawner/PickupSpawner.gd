extends Node2D

export (PackedScene) var pickup_scene

export var min_interval = 1
export var max_interval = 5

func _ready():
	randomize()
	$Timer.wait_time = rand_range(min_interval, max_interval)
	$Timer.start()

func _on_Timer_timeout():
	spawn()
	$Timer.wait_time = rand_range(min_interval, max_interval)
	$Timer.start()

func spawn():
	var pickup = pickup_scene.instance()
	pickup.global_position = global_position
	pickup.spawner_rotation = rotation
	get_parent().add_child(pickup)
