extends Area2D

export(Color) var hover_color = Color(1,1,1)
export(Color) var default_color = Color(0,0,0)
var available = false

onready var player = get_node("/root/Game/Player")
onready var sprite = $Sprite

func _ready():
	modulate = default_color

func _process(delta):
	if available and not sprite.visible:
		sprite.visible = true
	elif not available and sprite.visible:
		sprite.visible = false

func _on_GridSpace_input_event(viewport, event, shape_idx):
	if available and event is InputEventMouseButton and event.is_pressed():
		player.move(position)

func _on_GridSpace_area_shape_entered(area_id, area, area_shape, local_shape):
	if area.get_parent().name == "Player":
		available = true

func _on_GridSpace_area_shape_exited(area_id, area, area_shape, local_shape):
	if area.get_parent().name == "Player":
		available = false

func _on_GridSpace_mouse_entered():
	modulate = hover_color

func _on_GridSpace_mouse_exited():
	modulate = default_color
