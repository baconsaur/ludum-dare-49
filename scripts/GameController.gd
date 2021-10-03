extends Node2D

export(Array, PackedScene) var levels = []
export var level_start_position = Vector2(0, 200)
export var level_exit_position = Vector2(0, -200)
export var slide_level_speed = 50
export var shake_time = 0.1
export var shake_intensity = 1.5

var score = 0
var level_loaded = false
var animating_game_over = false
var level_cleared = true
var current_weather = null
var last_weather_effect = null
var current_level = null
var player = null
var weather_cards = []
var weather_card = preload("res://scenes/WeatherCard.tscn")
var player_obj = preload("res://scenes/Player.tscn")
var shake_countdown = 0
var shake = false
var scrolling_background = false
var background_reached_top = true

onready var constants = get_node("/root/Constants")
onready var rainbow = $Rainbow
onready var ui = $CanvasLayer/UI
onready var level_enter_sound = $LevelEnterSound
onready var level_poof_sound = $LevelPoofSound
onready var freeze_sound = $FreezeSound
onready var thaw_sound = $ThawSound
onready var music = $Music
onready var end_screen = $EndScreen
onready var background = $Background
onready var original_pos = position

func _ready():
	player = player_obj.instance()
	add_child(player)
	load_level()
	randomize()

func _process(delta):
	if not level_loaded:
		animate_load(delta)
	
	if not level_cleared:
		animate_clear(delta)
	
	if animating_game_over:
		animate_end_screen(delta)
	
	if shake:
		animate_shake(delta)
	
	if scrolling_background:
		scroll_background(delta)

func scroll_background(delta):
	if background.position.y > -180:
		background.position.y -= delta * slide_level_speed * 5
		if background_reached_top and background.position.y <= 0:
			background.position.y = 0
			scrolling_background = false
	else:
		background.position.y = 180
		background_reached_top = true

func animate_shake(delta):
	if shake_countdown > 0:
		shake_countdown -= delta
		position += Vector2(
			rand_range(-shake_intensity, shake_intensity),
			rand_range(-shake_intensity, shake_intensity)
		)
	else:
		position = original_pos
		shake = false

func animate_end_screen(delta):
	if end_screen.position.y > 0:
		end_screen.position.y -= delta * slide_level_speed * 3
	else:
		end_screen.position.y = 0
		animating_game_over = false
		ui.display_end(score)

func animate_clear(delta):
	if not is_equal_approx(player.position.y, level_exit_position.y):
		player.position.y = lerp(player.position.y, level_exit_position.y, delta * slide_level_speed / 2)
	else:
		player.position.y = level_exit_position.y
		level_cleared = true
		get_tree().paused = false
		next_level()

func animate_load(delta):
	if not current_level.position.is_equal_approx(Vector2.ZERO):
		current_level.position = lerp(current_level.position, Vector2.ZERO, delta * slide_level_speed)
	else:
		current_level.position = Vector2.ZERO
		level_loaded = true
		get_tree().paused = false

func step():
	current_level.shake()
	current_weather.remove()
	if len(weather_cards) > 1:
		current_level.decay(len(weather_cards) - 1)
		activate_weather()
	else:
		clean_up_level()

func start_shake():
	shake = true
	shake_countdown = shake_time

func update_score(value):
	score += value
	ui.update_score(score)

func finish_spawn():
	rainbow.visible = false

func clean_up_level():
	if weather_cards:
		var card = weather_cards[0]
		if card.current_weather == constants.DOWN:
			weather_cards[0].remove()
			weather_cards = []
	level_poof_sound.play()
	rainbow.visible = true
	current_level.clean_up()
	scrolling_background = true
	background_reached_top = false
	current_level.cloud_sprite.play("poof")
	current_level.cloud_sprite.connect("animation_finished", self, "transition_level")
	get_tree().paused = true

func transition_level():
	teardown()
	level_cleared = false

func next_level():
	get_tree().paused = false
	if levels:
		load_level()
	else:
		player.queue_free()
		animating_game_over = true

func load_level():
	level_enter_sound.play()
	rainbow.visible = true
	level_loaded = false
	get_tree().paused = true
	var next_level = levels.pop_front()
	current_level = next_level.instance()
	current_level.position = level_start_position
	add_child(current_level)
	set_up_weather()
	spawn_player()

func set_up_weather():
	for event in current_level.weather_events:
		add_weather_card(event)
	add_weather_card(constants.DOWN)
	activate_weather()

func add_weather_card(event):
	var new_card = weather_card.instance()
	weather_cards.append(new_card)
	ui.place_card(new_card)
	new_card.set_weather(event)

func activate_weather():
	if not weather_cards:
		return
	current_weather = weather_cards.pop_front()
	current_weather.activate()
	
	var weather_effect = current_weather.current_weather
	play_weather_sound(weather_effect)
	current_level.set_weather_effects(weather_effect)
	last_weather_effect = weather_effect

func teardown():
	if is_instance_valid(current_weather):
		current_weather.remove()
	for card in weather_cards:
		card.queue_free()
	weather_cards = []
	current_level.queue_free()

func play_weather_sound(weather_effect):
	if weather_effect == constants.SNOW:
		freeze_sound.play()
	elif last_weather_effect and last_weather_effect == constants.SNOW:
		thaw_sound.play()

func spawn_player():
	player.set_spawn(current_level.spawn_point.position)
	player.respawn()

func mute():
	music.stream_paused = true

func unmute():
	music.stream_paused = false
