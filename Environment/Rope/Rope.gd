extends Area2D

func _on_Rope_body_entered(body: Node) -> void:
	var player = body as Player
	player.touching_rope = true
	player.rope_position = global_position
	
func _on_Rope_body_exited(body: Node) -> void:
	var player = body as Player
	player.touching_rope = false
