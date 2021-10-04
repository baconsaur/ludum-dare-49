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

onready var target_position = position
onready var game = get_node("/root/Game")
onready var coin_sound = $CoinSound
onready var slide_sound = $SlideSound
onready var jump_sound = $JumpSound
onready var splash_sound = $SplashSound
onready var sprite = $Sprite


func _process(delta):
	if is_moving and not position.is_equal_approx(target_position):
		if start_position == null:
			start_position = position
		var progress = position.distance_to(start_position) / start_position.distance_to(target_position)
		var step = progress + delta * (move_speed if is_spawned else spawn_speed)
		position = lerp(start_position, target_position, step)
		if step > 1:
			position = target_position
	elif is_moving:
		position = target_position
		start_position = null
		is_moving = false
		
		if falling:
			falling = false
			game.clean_up_level()
			return
		
		if is_spawned:
			if len(game.weather_cards) <= 1:
				sprite.play("fall")
			else:
				play_idle_animation()
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

func slide():
	var slide_count = 0
	var start_position = global_position
	stop_next = false
	
	while check_slide(start_position):
		start_position += last_direction * 3
		slide_count += 1
		if stop_next:
			break
	target_position = position + last_direction * slide_count
	slide_sound.play()

func check_slide(start_position):
	var space_state = get_world_2d().direct_space_state
	
	var next_position = start_position + (last_direction * 3)
	var next_tile = next_position + tile_offset
	var next_tile_areas = space_state.intersect_point(
		next_tile, 1, [], 2147483647, false, true)

	for area in next_tile_areas:
		if "WaterGridSpace" in area.collider.name:
			return true
		if "GridSpace" in area.collider.name:
			stop_next = true
			return true

	return false

func fall_through(pos, mini_fall=false):
	if not mini_fall:
		falling = true
		move(pos)
		return
	var animation_direction = "front" if last_direction.y > 0 else "back"
	sprite.play("fall_through_" + animation_direction)
	sprite.frame = 4
	yield(get_tree().create_timer(0.5), "timeout")
	game.clean_up_level()
