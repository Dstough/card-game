extends Node


func move_to(control: Control, location: Vector2):
	var tween_movement = create_tween()
	tween_movement.set_ease(Tween.EASE_IN_OUT)
	tween_movement.set_trans(Tween.TRANS_CUBIC)
	tween_movement.tween_property(control, "global_position", location, .25)


func scale_to(control: Control, _size: float):
	var tween_hover = create_tween()
	tween_hover.set_ease(Tween.EASE_OUT)
	tween_hover.set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(control, "scale", Vector2(_size, _size), 0.5)


func lean_to(control: Control, _angle: float):
	var tween_tilt = create_tween()
	tween_tilt.set_ease(Tween.EASE_IN_OUT)
	tween_tilt.set_trans(Tween.TRANS_CUBIC)
	tween_tilt.tween_property(control, "rotation", deg_to_rad(_angle), 0.3)
