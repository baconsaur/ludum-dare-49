extends Area2D

export var value = 1
export var float_speed = 20

var collected = false

onready var sprite = $Sprite

func _process(delta):
	if collected:
		position.y -= delta * float_speed

func _on_Coin_body_entered(body):
	if body.name == "Player" and body.is_spawned:
		body.get_coin(value)
		sprite.play("pickup")
		sprite.connect("animation_finished", self, "queue_free")
		collected = true
