extends CanvasLayer

func _on_back_pressed() -> void:
	$".".visible = false
	get_tree().paused = false

func _on_leave_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu/menu.tscn")
