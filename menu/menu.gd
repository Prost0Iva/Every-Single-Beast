extends Node2D

func _on_button_play_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu_saves.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
