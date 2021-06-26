extends Node

func process(p: Player):
	if p.on_floor:
		p.has_jumped = false
		p.generic_state = Player.States.GROUND
		p.travel_to = "idle"

	elif not p.being_dragged:
		if p.has_jumped and p.vel.y < 0:
			if p.vel.x:
				p.travel_to = "jump_running"
			else:
				p.travel_to = "jump_in_place"
		else:
			p.travel_to = "fall"
	p.state_machine.travel(p.travel_to)
