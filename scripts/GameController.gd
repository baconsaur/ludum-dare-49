extends Node2D

export(Array, PackedScene) var levels = []

var score = 0

var current_weather = null
var weather_cards = []
var weather_card = preload("res://scenes/WeatherCard.tscn")

onready var constants = get_node("/root/Constants")
onready var player = $Player
onready var ui = $CanvasLayer/UI
onready var current_level = $Cloud

func _ready():
	set_up_weather()
	spawn_player()

func step():
	current_weather.remove()
	if weather_cards:
		activate_weather()
	else:
		end_level()

func end_level():
	load_next_level()

func load_next_level():
	teardown()
	if levels:
		var next_level = levels.pop_front()
		current_level = next_level.instance()
		add_child(current_level)
		set_up_weather()
		spawn_player()
	else:
		print("game over")

func set_up_weather():
	for event in current_level.weather_events:
		var new_card = weather_card.instance()
		weather_cards.append(new_card)
		ui.place_card(new_card)
		new_card.set_weather(event)
	activate_weather()

func activate_weather():
	if not weather_cards:
		return
	current_weather = weather_cards.pop_front()
	current_weather.activate()
	current_level.set_weather_effects(current_weather.current_weather)

func teardown():
	if current_weather:
		current_weather.remove()
	for card in weather_cards:
		card.queue_free()
	weather_cards = []
	current_level.queue_free()

func spawn_player():
	player.set_spawn(current_level.spawn_point.position)
	player.respawn()
