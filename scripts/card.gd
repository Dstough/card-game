extends Button

@export_category("Hover Values")
@export var scale_amount: float = 1.5
@export var max_offset_shadow: float = 50

@export_category("Tilt Values")
@export var angle_x_max: float = 15
@export var angle_y_max: float = 15

@export_category("Oscillator")
@export var spring: float = 150
@export var damp: float = 10
@export var velocity_multiplier: float = 1

var card_texture: TextureRect
var card_shadow: TextureRect
var card_base: TextureRect

var burning_material: Material

var tween_rotation: Tween
var tween_hover: Tween
var tween_tilt: Tween
var tween_lean: Tween
var tween_destroy: Tween

var original_scale: Vector2
var velocity: Vector2
var last_position: Vector2

var following_mouse: bool
var being_destroyed: bool

var displacement: float
var oscillator_velocity: float

#region signals

func _ready():
	card_texture = $CardTexture
	card_shadow = $CardShadow
	card_base = $".."
	
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)
	
	following_mouse = false;
	original_scale = scale
	pivot_offset = Vector2(size.x / 2, size.y / 2)
	burning_material = load("res://materials/burn_away.tres").duplicate()


func _process(_delta):
	handle_shadow_position()
	handle_card_following_mouse()
	handle_card_lean(_delta)


func _on_gui_input(_event):
	handle_mouse_clicks(_event)
	handle_card_tilting()


func _on_mouse_entered():
	handle_card_focus()


func _on_mouse_exited():
	handle_card_blur()


#endregion

#region handlers

func handle_card_focus():
	
	Util.scale_to(self, scale_amount)
	z_index += 1


func handle_card_blur():
	tilt_to(0.0, 0.0)
	Util.scale_to(self, 1)
	z_index -= 1


func handle_shadow_position():
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	card_shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance / (center.x)))


func handle_mouse_clicks(event):
	if not event is InputEventMouseButton: 
		return
		
	if event.is_pressed():
		
		if not being_destroyed:
			match event.button_index:
				MOUSE_BUTTON_RIGHT:
					being_destroyed = true;
					destory()
					return
				
		following_mouse = true
		self.get_parent().move_child(self, -1)
	else:
		following_mouse = false
		Util.lean_to(self, 0)
		Util.move_to(self, card_base.global_position)


func handle_card_following_mouse():
	if not following_mouse:
		return
	
	var mouse_position = get_global_mouse_position()
	
	global_position = mouse_position - (size / 2.0)


func handle_card_tilting():
	var mouse_position: Vector2 = get_local_mouse_position()
	
	var lerp_value_x: float = remap(mouse_position.x, 0.0, size.x, 0, 1)
	var lerp_value_y: float = remap(mouse_position.y, 0.0, size.y, 0, 1)
	
	var rotation_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_value_x))
	var rotation_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_value_y))
	
	# Why the f*ck are these reversed?!?
	# Somehow it works but I can't grasp exactly why.
	card_texture.material.set_shader_parameter("x_rot", rotation_y)
	card_texture.material.set_shader_parameter("y_rot", rotation_x)


func handle_card_lean(delta):
	if not following_mouse: 
		return
	
	velocity = (position - last_position) / delta
	last_position = position
	
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damp * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement


#endregion

#region utility


func tilt_to(_angle_x, _angle_y):
	if tween_rotation and tween_rotation.is_running():
		tween_rotation.kill()
	tween_rotation = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rotation.tween_property(card_texture.material, "shader_parameter/x_rot", _angle_x, 0.5)
	tween_rotation.tween_property(card_texture.material, "shader_parameter/y_rot", _angle_y, 0.5)


#endregion

#region commands

func destory():
	card_texture.material = burning_material
	card_shadow.material = burning_material
	
	if tween_destroy and tween_destroy.is_running():
		tween_destroy.kill()
	tween_destroy = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_destroy.tween_property(burning_material, "shader_parameter/dissolve_value", 0.0, 2)
	tween_destroy.tween_callback(queue_free)
	tween_destroy.tween_callback(card_base.queue_free)


#endregion
