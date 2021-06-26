extends Area2D

export var speed := 20.0
var dir: Vector2
var spawner_rotation: float

func _ready():
	randomize()
	dir = Vector2(
		cos(spawner_rotation) + rand_range(-1.0, +1.0), 
		sin(spawner_rotation) + rand_range(-1.0, +1.0)
	).normalized()

func _process(delta):
	position += dir * speed * delta

func _on_Timer_timeout():
	queue_free()

func _on_Pickup_area_entered(body):
	print(body.name)

	if body.name == "HurtBox":
		queue_free()