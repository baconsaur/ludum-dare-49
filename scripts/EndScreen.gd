extends Control

export var count_time = 0.2

var total_score = 0
var counted_score = 0
var count_cooldown = 0
var celebration_coin = preload("res://scenes/CelebrationCoin.tscn")
var done = false

onready var coin_sound = $CoinSound
onready var score_count = $CenterContainer/HBoxContainer/ScoreCount


func _process(delta):
	if done:
		return

	count_cooldown -= delta
	if count_cooldown <= 0:
		count_cooldown = count_time
		count_point()

func count_point():
	if counted_score >= total_score:
		done = true
		return
		
	counted_score += 1
	coin_sound.play()
	var coin = celebration_coin.instance()
	add_child(coin)
	coin.global_position = score_count.rect_global_position + Vector2(80, 20)
	coin.position += Vector2(rand_range(-20, 20), rand_range(-20, 20))
	score_count.text = str(counted_score)

func count_score(score):
	total_score = score
	count_cooldown = count_time

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_MenuButton_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")
