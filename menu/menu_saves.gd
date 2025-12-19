extends Node2D

func _on_save_1_pressed() -> void:
	get_tree().change_scene_to_file("res://gameplay/save_1.tscn")
func _on_delete_save_1_pressed() -> void:
	if FileAccess.file_exists("user://save_1.save"):
		DirAccess.remove_absolute("user://save_1.save")
