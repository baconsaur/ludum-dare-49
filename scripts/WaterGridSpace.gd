extends "res://scripts/GridSpace.gd"

onready var effect_sprite = $EffectSprite
onready var default_sprite = preload("res://sprites/water_tile.png")
onready var rain_sprite = preload("res://sprites/water_tile_rain.png")
onready var snow_sprite = preload("res://sprites/water_tile_snow.png")
onready var storm_sprite = preload("res://sprites/water_tile_storm.png")

func set_weather(new_weather):
	weather = new_weather
	if weather == constants.STORM:
		effect_sprite.texture = storm_sprite
	elif weather == constants.RAIN:
		effect_sprite.texture = rain_sprite
	elif weather == constants.SNOW:
		effect_sprite.texture = snow_sprite
	else:
		effect_sprite.texture = default_sprite

func set_available():
	if not weather == constants.STORM:
		available = true
		grid_sprite.modulate = available_color

func affect_player():
	if weather == constants.STORM:
		player.respawn()
	if weather == constants.RAIN:
		game.load_next_level()
	if weather == constants.SNOW:
		player.slide()
