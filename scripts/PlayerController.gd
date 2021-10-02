extends Node2D

export var tile_offset = Vector2(0, 8)
export var move_speed = 30
export var spawn_speed = 20
export var spawn_offset = Vector2(0, 158)

var spawn = Vector2.ZERO
var score = 0
var last_direction = null
var is_moving = false
var is_spawned = false
var directions = null
var direction_colliders = preload("res://scenes/Directions.tscn")

onready var target_position = position
onready var game = get_node("/root/Game")
onready var coin_sound = $CoinSound
onready var slide_sound = $SlideSound


func _process(delta):
	if is_moving and not position.is_equal_approx(target_position):
		position = lerp(position, target_position, delta * (move_speed if is_spawned else spawn_speed))
	elif is_moving:
		position = target_position
		is_moving = false
		if is_spawned:
			game.step()
		else:
			is_spawned = true
			directions = direction_colliders.instance()
			add_child(directions)
			game.finish_spawn()

func set_spawn(pos):
	spawn = pos - tile_offset
	
func move(pos):
	if is_moving:
		return
	target_position = pos - tile_offset
	last_direction = ( target_position - position )
	is_moving = true

func get_coin(value):
	coin_sound.play()
	score += value

func respawn():
	if directions:
		directions.queue_free()
	is_spawned = false
	position = spawn - spawn_offset
	target_position = spawn
	is_moving = true

func slide():
	var slide_count = 0
	var start_position = global_position

	while check_slide(start_position):
		start_position += last_direction * 3
		slide_count += 1
	target_position = position + last_direction * slide_count
	slide_sound.play()

func check_slide(start_position):
	var space_state = get_world_2d().direct_space_state
	
	var next_position = start_position + (last_direction * 3)
	var next_tile = next_position + tile_offset
	var next_tile_areas = space_state.intersect_point(
		next_tile, 1, [], 2147483647, false, true)

	for area in next_tile_areas:
		if "GridSpace" in area.collider.name:
			return true

	return false
