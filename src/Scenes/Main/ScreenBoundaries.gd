extends Area2D

func _on_SideBoundaries_area_entered(body):
	if body.name == "HurtBox":
		var player = body.get_parent() as Player
		player.throw(player.vel.x < 0)