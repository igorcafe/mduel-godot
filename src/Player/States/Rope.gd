extends Node

func process(p: Player):
	var travel_to = "idle"
	if not p.vel.x:
		p.vel.x = (int(p.p_right) - int(p.p_left)) * p.rope_speed

	if p.vel.x or not p.touching_rope:
		p.set_collision_mask_bit(Global.Layers.GROUND, true)
		p.set_collision_mask_bit(Global.Layers.ROPE_ENDS, false)
		p.gravity = p.default_gravity
		p.generic_state = Player.States.GROUND
	else:
		p.set_collision_mask_bit(Global.Layers.GROUND, false)
		p.set_collision_mask_bit(Global.Layers.ROPE_ENDS, true)
		p.global_position.x = p.rope_position.x
		p.gravity = 0
		p.vel.y = (int(p.p_down) - int(p.p_up)) * p.rope_speed
		if p.vel.y:
			travel_to = "rope_climbing"
		else:
			travel_to = "rope_idle"
	p.state_machine.travel(travel_to)
