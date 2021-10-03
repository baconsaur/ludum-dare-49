extends Control

var end_screen = preload("res://scenes/EndScreen.tscn")
var muted = false

onready var weather_container = $CenterContainer/WeatherContainer
onready var score_container = $Score
onready var coin_icon = $CoinIcon
onready var mute_sprite = $MuteButton/Sprite
onready var game = get_node("/root/Game")


func place_card(card):
	weather_container.add_child(card)

func update_score(score):
	score_container.text = str(score)

func display_end(score):
	score_container.queue_free()
	weather_container.queue_free()
	coin_icon.queue_free()
	var end = end_screen.instance()
	add_child(end)
	end.count_score(score)


func _on_Button_pressed():
	if muted:
		game.unmute()
		mute_sprite.play("unmuted")
		muted = false
	else:
		game.mute()
		mute_sprite.play("muted")
		muted = true
