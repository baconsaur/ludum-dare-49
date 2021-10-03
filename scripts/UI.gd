extends Control

var end_screen = preload("res://scenes/EndScreen.tscn")

onready var weather_container = $CenterContainer/WeatherContainer
onready var score_container = $Score
onready var coin_icon = $CoinIcon


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
