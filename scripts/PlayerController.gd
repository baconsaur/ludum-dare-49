extends Node2D

export var tile_offset = Vector2(0, 8)
export var move_speed = 2.8
export var spawn_speed = 2.3
export var spawn_offset = Vector2(0, 158)
export var fall_time = 5

var spawn = Vector2.ZERO
var last_direction = null
var is_moving = false
var is_spawned = false
var directions = null
var direction_colliders = preload("res://scenes/Directions.tscn")
var start_position = null
var stop_next = false
var fall_countdown = 0
var falling = false
var movement_disabled = false
var wind_direction = Vector2(-16, 8)
var free_move = false
var should_add_wind = false

onready var target_position = position
onready var game = get_node("/root/Game")
onready var constants = get_node("/root/Constants")
onready var coin_sound = $CoinSound
onready var slide_sound = $SlideSound
onready var jump_sound = $JumpSound
onready var splash_sound = $SplashSound
onready var sprite = $Sprite


func _process(delta):
	if is_moving and not position.is_equal_approx(target_position):
		slide_character(delta)

func slide_character(delta):
	if start_position == null:
		start_position = position
	var progress = position.distance_to(start_position) / start_position.distance_to(target_position)
	var step = progress + delta * (move_speed if is_spawned else spawn_speed)
	position = lerp(start_position, target_position, step)
	if step > 1:
		position = target_position
	if position.is_equal_approx(target_position):
		position = target_position
		start_position = null
		is_moving = false
		if should_add_wind:
			add_wind()
		else:
			end_movement()

func end_movement():
	if falling:
		falling = false
		game.clean_up_level()
		return

	if is_spawned:
		if len(game.weather_cards) <= 1:
			sprite.play("fall")
		else:
			play_idle_animation()
			if should_add_wind:
				add_wind()
		game.step()
	else:
		sprite.play("land")
		game.start_shake()
		splash_sound.play()
		sprite.connect("animation_finished", self, "play_idle_animation")
		is_spawned = true
		directions = direction_colliders.instance()
		add_child(directions)
		game.finish_spawn()

func play_idle_animation():
	sprite.disconnect("animation_finished", self, "play_idle_animation")
	var animation_direction = "front" if not last_direction or last_direction.y > 0 else "back"
	sprite.play("idle_" + animation_direction)

func set_spawn(pos):
	spawn = pos - tile_offset

func move(pos):
	if is_moving:
		return
	jump_sound.play()
	target_position = pos - tile_offset
	last_direction = ( target_position - position )
	is_moving = true
	
	var prefix = "fall_through_" if falling else "jump_"
	
	var animation_direction = "front" if last_direction.y > 0 else "back"
	if last_direction.x < 0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	sprite.play(prefix + animation_direction)

func get_coin(value):
	coin_sound.play()
	game.update_score(value)

func respawn():
	if directions:
		directions.queue_free()
	is_spawned = false
	position = spawn - spawn_offset
	target_position = spawn
	last_direction = null
	is_moving = true
	sprite.play("fall")

func queue_wind():
	should_add_wind = true

func add_wind():
	should_add_wind = false
	var new_start_position = global_position
	if check_slide(new_start_position, wind_direction):
		target_position += wind_direction
		slide_sound.play()
		is_moving = true
	else:
		end_movement()

func slide():
	var slide_count = 0
	var new_start_position = global_position
	stop_next = false

	while check_slide(new_start_position, last_direction):
		new_start_position += last_direction * 3
		slide_count += 1
		if stop_next:
			break
	target_position = position + last_direction * slide_count
	slide_sound.play()

func check_slide(new_start_position, direction, wind=false):
	var space_state = get_world_2d().direct_space_state
	
	var next_position = new_start_position + (direction * 3)
	var next_tile = next_position + tile_offset
	var next_tile_areas = space_state.intersect_point(
		next_tile, 1, [], 2147483647, false, true)

	for area in next_tile_areas:
		if "WaterGridSpace" in area.collider.name:
			return true
		if "GridSpace" in area.collider.name:
			if not wind:
				stop_next = true
			return true

	return false

func fall_through(pos, mini_fall=false):
	if not mini_fall:
		falling = true
		move(pos)
		return
	movement_disabled = true
	var animation_direction = "front" if last_direction.y > 0 else "back"
	sprite.play("fall_through_" + animation_direction)
	sprite.frame = 4
	yield(get_tree().create_timer(0.5), "timeout")
	game.clean_up_level()
	movement_disabled = false
