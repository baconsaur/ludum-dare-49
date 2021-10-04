extends Control

export var game_scene = "res://scenes/Game.tscn"


func _on_StartButton_pressed():
	get_tree().change_scene(game_scene)

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_CreditsButton_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

func _on_MenuButton_pressed():
	get_tree().change_scene("res://scenes/Menu.tscn")
