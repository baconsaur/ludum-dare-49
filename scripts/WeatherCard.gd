extends Control

export var pulse_speed = 30
export var exit_speed = 1000
export var exit_y = -350

var active = false
var temp_duplicate = null
var is_leaving = false

onready var constants = get_node("/root/Constants")
onready var current_weather = constants.SUN
onready var sprite = $AnimatedSprite

func _process(delta):
	if is_leaving:
		if is_instance_valid(temp_duplicate):
			temp_duplicate.queue_free()
		sprite.position.y -= delta * exit_speed
		if sprite.position.y <= exit_y:
			queue_free()

	if is_instance_valid(temp_duplicate):
		temp_duplicate.scale += Vector2(delta * pulse_speed, delta * pulse_speed)
		temp_duplicate.modulate.a -= delta * pulse_speed / 8
		if current_weather == constants.DOWN:
			sprite.scale += Vector2(delta * pulse_speed * 3, delta * pulse_speed * 3)
			sprite.modulate.a -= delta * pulse_speed / 6
		if temp_duplicate.modulate.a <= 0:
			temp_duplicate.queue_free()
			if current_weather == constants.DOWN:
				queue_free()

func set_weather(weather_state):
	current_weather = weather_state
	sprite.set_animation(current_weather)
	if active:
		display_active()
	if current_weather == constants.DOWN:
		modulate = Color(1,1,1)
		sprite.modulate = Color("3d80a3")

func activate():
	active = true
	display_active()

func display_active():
	temp_duplicate = sprite.duplicate()
	get_parent().add_child(temp_duplicate)
	sprite.play()
	modulate = Color(1,1,1)

func remove():
	if current_weather == constants.DOWN:
		remove_down_arrow()
		return
	sprite.stop()
	sprite.modulate = Color("3d80a3")
	var old_global_pos = rect_global_position
	var parent = get_parent()
	parent.remove_child(self)
	parent.get_parent().get_parent().add_child(self)
	rect_global_position = old_global_pos
	is_leaving = true
	sprite.stop()

func remove_down_arrow():
	sprite.modulate = Color(1,1,1)
	temp_duplicate = sprite.duplicate()
	get_parent().add_child(temp_duplicate)
