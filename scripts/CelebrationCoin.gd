extends AnimatedSprite

func _ready():
	play()

func _on_CelebrationCoin_animation_finished():
	queue_free()
