extends StaticBody2D

@export var health: float = 15

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
	
	#print($"..".world_data["Chunks"][chunk]["Objects"][tile]["Scene"])
	#print($"..".world_data["Chunks"][chunk]["Objects"][tile])
	#print($"..".world_data["Chunks"][chunk]["Objects"])
	#print($"..".world_data["Chunks"][chunk])
	
	if $"..".world_data["Chunks"][chunk]["Objects"][tile]["Scene"] == self:
		$"..".world_data["Chunks"][chunk]["Objects"].erase(tile)
		queue_free()
