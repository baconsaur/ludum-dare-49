extends "res://scripts/GridSpace.gd"

onready var effect_sprite = $EffectSprite

func set_weather(new_weather):
	weather = new_weather
	if weather == constants.STORM:
		effect_sprite.play(constants.STORM)
	elif weather == constants.RAIN:
		effect_sprite.play(constants.RAIN)
		if player.position.is_equal_approx(position + player.tile_offset):
			player.fall_through(position, true)
	elif weather == constants.SNOW:
		effect_sprite.play(constants.SNOW)
	else:
		effect_sprite.play("default")


func set_available():
	available = true
	grid_sprite.modulate = available_color

func affect_player():
	if weather == constants.STORM:
		player.respawn()
	if weather == constants.RAIN:
		player.fall_through(position)
	if weather == constants.SNOW:
		.affect_player()
		player.slide()
	else:
		.affect_player()
