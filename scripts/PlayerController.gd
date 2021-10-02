extends Node2D

export var tile_offset = Vector2(0, 8)

var spawn = Vector2.ZERO
var score = 0

func set_spawn(pos):
	spawn = pos
	
func move(pos):
	position = pos - tile_offset

func get_coin(value):
	score += value

func respawn():
	position = spawn - tile_offset

func slide():
	print("SLIDE")
