extends RayCast3D

func get_board_position() -> Vector3:
	return Vector3(clamp(get_collision_point().floor().x + .5, 0.5, 7.5), get_collision_point().floor().y, clamp(get_collision_point().floor().z + .5, -7.5, -.5)) if is_colliding() else null
