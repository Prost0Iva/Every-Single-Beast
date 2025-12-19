extends StaticBody2D


func _on_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var tween = get_tree().create_tween()
		tween.tween_property($Area/CollisionShape2/Leaves, "self_modulate:a", 0.3, 0.5)


func _on_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		var tween = get_tree().create_tween()
		tween.tween_property($Area/CollisionShape2/Leaves, "self_modulate:a", 1.0, 0.5)
