extends Control

var active = false

onready var constants = get_node("/root/Constants")
onready var current_weather = constants.CLOUD
onready var sprite = $AnimatedSprite


func set_weather(weather_state):
	current_weather = weather_state
	sprite.set_animation(current_weather)
	if active:
		display_active()

func activate():
	active = true
	display_active()

func display_active():
	sprite.play()
	modulate = Color(1,1,1)

func remove():
	queue_free()
