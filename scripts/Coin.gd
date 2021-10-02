extends Area2D

export var value = 1


func _on_Coin_body_entered(body):
	if body.name == "Player" and body.is_spawned:
		body.get_coin(value)
		queue_free()
