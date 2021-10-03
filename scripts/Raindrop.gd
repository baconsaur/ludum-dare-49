extends AnimatedSprite

export var min_drop_speed = 300
export var max_drop_speed = 400
export var exit_y = 400


func _process(delta):
	position. y += delta * rand_range(min_drop_speed / 2, max_drop_speed)
	if position.y > exit_y:
		queue_free()
	
