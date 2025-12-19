extends CanvasLayer


func _on_up_button_down() -> void:
	Input.action_press("Up")
func _on_up_button_up() -> void:
	Input.action_release("Up")

func _on_left_button_down() -> void:
	Input.action_press("Left")
func _on_left_button_up() -> void:
	Input.action_release("Left")

func _on_right_button_down() -> void:
	Input.action_press("Right")
func _on_right_button_up() -> void:
	Input.action_release("Right")


func _on_down_button_down() -> void:
	Input.action_press("Down")
func _on_down_button_up() -> void:
	Input.action_release("Down")
