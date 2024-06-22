extends Button


@export var angle_x_max: float
@export var angle_y_max: float
@export var scale_amount: float
@export var max_offset_shadow: float

var card_texture: TextureRect
var card_shadow: TextureRect
var tween_rotation: Tween
var tween_hover: Tween
var original_scale: Vector2


func _ready():
	card_texture = $CardTexture
	card_shadow = $CardShadow
	
	original_scale = scale
	pivot_offset = Vector2(size.x / 2, size.y / 2)


func _process(_delta):
	handle_shadows();


func _on_gui_input(_event):
	
	#Handle Rotation
	var mouse_position: Vector2 = get_local_mouse_position()
	
	var lerp_value_x: float = remap(mouse_position.x, 0.0, size.x, 0, 1)
	var lerp_value_y: float = remap(mouse_position.y, 0.0, size.y, 0, 1)
	
	var rotation_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_value_x))
	var rotation_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_value_y))
	
	# Why the f*ck are these reversed?!?
	card_texture.material.set_shader_parameter("x_rot", rotation_y)
	card_texture.material.set_shader_parameter("y_rot", rotation_x)


func _on_mouse_entered() -> void:
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(scale_amount, scale_amount), 0.5)	
	
	z_index += 1


func _on_mouse_exited() -> void:
	# Reset Rotation
	if tween_rotation and tween_rotation.is_running():
		tween_rotation.kill()
	tween_rotation = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rotation.tween_property(card_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rotation.tween_property(card_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset Scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, .55)
	
	z_index -= 1


func handle_shadows() -> void:
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	card_shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / (center.x)))
