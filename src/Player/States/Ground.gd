extends Node

func process(p: Player):
	if not p.on_floor:
		p.generic_state = Player.States.AIR
		return
	
	p.being_dragged = false
	p.can_move_x = p.state() in [ "idle", "run" ]
	p.can_jump = p.can_move_x
	p.travel_to = "idle"

	if p.can_move_x:
		p.vel.x = 0
		if p.p_right:
			p.vel.x = +p.move_speed
			p.travel_to = "run"
			p.flip_h()
		elif p.p_left:
			p.vel.x = -p.move_speed
			p.travel_to = "run"
			p.flip_h()

	if p.touching_rope and not p.vel.x and (p.p_up or p.p_down):
		p.generic_state = Player.States.ROPE
		p.travel_to = "rope_climbing"
	else:
		if p.jp_up and p.can_jump and not p.has_jumped:
			p.can_move_x = false
			p.has_jumped = true
			p.jump()
			p.generic_state = Player.States.AIR
		elif p.jp_down and p.vel.x:
			p.can_move_x = false
			p.can_jump = false
			p.travel_to = "roll_forward"
		elif p.p_down and not p.vel.x:
			p.can_move_x = false
			p.can_jump = false
			p.travel_to = "duck"
	p.state_machine.travel(p.travel_to)
