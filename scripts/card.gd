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
var followring_mouse: bool


func _ready():
	card_texture = $CardTexture
	card_shadow = $CardShadow
	
	followring_mouse = false;
	original_scale = scale
	pivot_offset = Vector2(size.x / 2, size.y / 2)


func _process(_delta):
	handle_shadow_position()
	handle_card_following_mouse()


func _on_gui_input(_event):
	handle_mouse_click(_event)
	handle_card_tilting()


func _on_mouse_entered() -> void:
	handle_card_focus()


func _on_mouse_exited() -> void:
	handle_card_blur()


func handle_card_focus():	
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(scale_amount, scale_amount), 0.5)	
	
	z_index += 1


func handle_card_blur():
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


func handle_shadow_position():
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	card_shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / (center.x)))


func handle_mouse_click(event):
	if not event is InputEventMouseButton: 
		return
	
	if event.is_pressed():
		followring_mouse = true
		GameManager.local_player_is_holding_card = true
		self.get_parent().move_child(self, -1)
	else:
		followring_mouse = false
		GameManager.local_player_is_holding_card = false


func handle_card_following_mouse():
	if not followring_mouse:
		return
	
	var mouse_position = get_global_mouse_position()
	
	global_position = mouse_position - (size / 2.0)


func handle_card_tilting():

	#Handle Rotation
	var mouse_position: Vector2 = get_local_mouse_position()
	
	var lerp_value_x: float = remap(mouse_position.x, 0.0, size.x, 0, 1)
	var lerp_value_y: float = remap(mouse_position.y, 0.0, size.y, 0, 1)
	
	var rotation_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_value_x))
	var rotation_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_value_y))
	
	# Why the f*ck are these reversed?!?
	card_texture.material.set_shader_parameter("x_rot", rotation_y)
	card_texture.material.set_shader_parameter("y_rot", rotation_x)
