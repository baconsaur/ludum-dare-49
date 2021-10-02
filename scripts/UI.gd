extends Control

onready var weather_container = $CenterContainer/WeatherContainer


func place_card(card):
	weather_container.add_child(card)
