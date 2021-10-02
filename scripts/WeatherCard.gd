extends Control

var active = false

onready var constants = get_node("/root/Constants")
onready var current_weather = constants.CLOUD
onready var sprite = $AnimatedSprite


func set_weather(weather_state):
	current_weather = weather_state
	sprite.set_animation(current_weather)
	if active:
		sprite.play()

func activate():
	active = true
	sprite.play()

func remove():
	queue_free()
