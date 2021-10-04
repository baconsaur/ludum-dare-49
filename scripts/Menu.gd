extends Node2D

export var scroll_speed = 80
onready var clouds = $Clouds
onready var clouds2 = $Clouds2

func _process(delta):
	clouds.position.x += delta * scroll_speed
	clouds2.position.x += delta * scroll_speed

	if clouds.position.x >= 875:
		clouds.position.x = -1008

	if clouds2.position.x >= 875:
		clouds2.position.x = -1008
