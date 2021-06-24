extends Area2D

func _on_ScreenBoundaries_body_entered(body: Node) -> void:
	var player = body as Player
	player.thrown_backwards()
