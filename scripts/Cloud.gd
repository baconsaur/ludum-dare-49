extends Node2D

export(Array, String) var weather_events
export var shake_time = 0.08
export var max_drops = 6
export var drop_spawn_min_x = -50
export var drop_spawn_max_x = 50

var shake_countdown = 0
var shake = false
var raindrop_sprite = preload("res://scenes/Raindrop.tscn")
var raindrops = []
var current_weather = null

onready var constants = get_node("/root/Constants")
onready var grid = $Grid
onready var spawn_point = $SpawnPoint
onready var cloud_sprite = $CloudSprite


func _process(delta):
	if not shake:
		return

	if shake_countdown > 0:
		shake_countdown -= delta
		cloud_sprite.position += Vector2(rand_range(-0.4, 0.4), rand_range(-0.4, 0.4))
	else:
		cloud_sprite.position = Vector2.ZERO
		shake = false

func set_weather_effects(weather):
	current_weather = weather
	for child in grid.get_children():
		child.set_weather(weather)

func clean_up():
	grid.queue_free()
	spawn_point.queue_free()

func decay(steps_left):
	cloud_sprite.play("decay_" + str(steps_left))

func shake():
	shake = true
	shake_countdown = shake_time
	
	var num_drops = rand_range(3, max_drops)
	for i in range(num_drops):
		var drop = raindrop_sprite.instance()
		add_child(drop)
		drop.position.x = rand_range(drop_spawn_min_x, drop_spawn_max_x)
		if current_weather and current_weather == constants.SNOW:
			drop.play(constants.SNOW)
