extends StaticBody2D

@export var health: float = 15:
	set(value):
		if health == value:
			return
		health = value
		damaged()

func _physics_process(_delta: float) -> void:
	if health <= 0:
		die()

func _on_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var tween = get_tree().create_tween()
		tween.tween_property($Area/CollisionShape2/Leaves, "self_modulate:a", 0.3, 0.5)

func _on_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		var tween = get_tree().create_tween()
		tween.tween_property($Area/CollisionShape2/Leaves, "self_modulate:a", 1.0, 0.5)

func die():
	var tile= str(WorldGen.pos_convert(position, "Def", "Tile"))
	var chunk = str(WorldGen.pos_convert(position, "Def", "Chunk"))
	
	if $"..".world_data["Chunks"][chunk]["Objects"][tile]["Scene"] == self:
		$"..".world_data["Chunks"][chunk]["Objects"].erase(tile)
		queue_free()

func damaged():
	var tween_1 = get_tree().create_tween()
	var tween_2 = get_tree().create_tween()
	var tween_3 = get_tree().create_tween()
	var tween_4 = get_tree().create_tween()
	var tween_5 = get_tree().create_tween()
	var tween_6 = get_tree().create_tween()
	tween_1.tween_property($CollisionShape/Oak, "self_modulate:r", 1.5, .2)
	tween_2.tween_property($CollisionShape/Oak, "self_modulate:g", 1.5, .2)
	tween_3.tween_property($CollisionShape/Oak, "self_modulate:b", 1.5, .2)
	
	tween_1.tween_property($CollisionShape/Oak, "self_modulate:r", 1, .2)
	tween_2.tween_property($CollisionShape/Oak, "self_modulate:g", 1, .2)
	tween_3.tween_property($CollisionShape/Oak, "self_modulate:b", 1, .2)
	
	tween_4.tween_property($Area/CollisionShape2/Leaves, "self_modulate:r", 1.5, .2)
	tween_5.tween_property($Area/CollisionShape2/Leaves, "self_modulate:g", 1.5, .2)
	tween_6.tween_property($Area/CollisionShape2/Leaves, "self_modulate:b", 1.5, .2)
	
	tween_4.tween_property($Area/CollisionShape2/Leaves, "self_modulate:r", 1, .2)
	tween_5.tween_property($Area/CollisionShape2/Leaves, "self_modulate:g", 1, .2)
	tween_6.tween_property($Area/CollisionShape2/Leaves, "self_modulate:b", 1, .2)
