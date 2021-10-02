extends Node2D

export var tile_offset = Vector2(0, 8)

func move(pos):
	position = pos - tile_offset
