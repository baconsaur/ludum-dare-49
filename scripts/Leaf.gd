extends AnimatedSprite

export var min_float_speed = 80
export var max_float_speed = 400
export var max_enter_y = 100
export var min_enter_y = -500

func _ready():
	randomize()
	position = Vector2(400, rand_range(min_enter_y, max_enter_y))

func _process(delta):
	position.y += delta * rand_range(min_float_speed * 0.8, max_float_speed * 0.8)
	position.x -= delta * rand_range(min_float_speed * 1.2, max_float_speed * 1.2)
	if position.x < -400:
		queue_free()
	
