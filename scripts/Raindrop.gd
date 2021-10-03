extends AnimatedSprite

export var min_drop_speed = 300
export var max_drop_speed = 400
export var exit_y = 400


func _process(delta):
	var modifier = 1
	if animation == "snow":
		modifier = 0.4
	position. y += delta * rand_range(min_drop_speed / 2 * modifier, max_drop_speed * modifier)
	if position.y > exit_y:
		queue_free()
	
