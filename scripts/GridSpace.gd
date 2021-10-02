extends Area2D

export(Color) var hover_color = Color(1,1,1)
export(Color) var available_color = Color(0,0,0)
var available = false

onready var constants = get_node("/root/Constants")
onready var player = get_node("/root/Game/Player")
onready var grid_sprite = $GridSprite
onready var cloud = get_parent()
onready var game = get_node("/root/Game")
onready var inactive_color = grid_sprite.modulate
onready var weather = constants.CLOUD

func _process(delta):
	if player.is_moving and grid_sprite.visible:
		grid_sprite.visible = false
	elif not player.is_moving and not grid_sprite.visible:
		grid_sprite.visible = true

func set_weather(new_weather):
	weather = new_weather

func set_available():
		available = true
		grid_sprite.modulate = available_color

func _on_GridSpace_input_event(viewport, event, shape_idx):
	if player.is_moving or not available:
		return
	if event is InputEventMouseButton and event.is_pressed():
		player.move(position)
		affect_player()

func affect_player():
	pass

func _on_GridSpace_area_shape_entered(area_id, area, area_shape, local_shape):
	if area.name == "Directions":
		set_available()

func _on_GridSpace_area_shape_exited(area_id, area, area_shape, local_shape):
	if not area:
		return

	if area.name == "Directions":
		available = false
		grid_sprite.modulate = inactive_color

func _on_GridSpace_mouse_entered():
	if available:
		grid_sprite.modulate = hover_color

func _on_GridSpace_mouse_exited():
	if available:
		grid_sprite.modulate = available_color
	else:
		grid_sprite.modulate = inactive_color
