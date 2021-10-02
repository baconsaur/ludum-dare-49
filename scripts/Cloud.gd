extends Node2D

export(Array, String) var weather_events

onready var grid = $Grid
onready var spawn_point = $SpawnPoint
onready var cloud_sprite = $CloudSprite

func set_weather_effects(weather):
	for child in grid.get_children():
		child.set_weather(weather)
