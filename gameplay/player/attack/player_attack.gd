extends Area2D

@export var damage: float

var hb_none = load("res://gameplay/player/attack/none.tres")
var hb_fist = load("res://gameplay/player/attack/fist.tres")

func _input(_event):
	if Input.is_action_just_pressed("LClick"):
		attack()

func attack():
	#Позиция курсора
	var mouse_pos = get_global_mouse_position()
	#Вектор курсора
	var direction_to_mouse = mouse_pos - $"..".position
		#Расстояние до курсора
	var distance_to_mouse = direction_to_mouse.length()
	#Угол вектора курсора в радианах
	var angle_degrees = direction_to_mouse.angle()
	
	
	if !$Sprite.is_playing():
		damage = 1
		
		$".".rotation = angle_degrees
		$Hitbox.shape = hb_fist
		var hb_scale: float = min(max(distance_to_mouse * .04, 1), 2.5)
		$Hitbox.scale = Vector2(hb_scale, hb_scale)
		$Sprite.scale = Vector2(hb_scale, hb_scale)
		$Sprite.play("fist", min(max((200/distance_to_mouse), .5), 2.5))
		#print($".".rotation,"\n", angle_degrees)
	

func _on_sprite_animation_finished() -> void:
	damage = 0
	
	$Hitbox.shape = hb_none
	$Sprite.animation = "default"
	$Sprite.stop()
	#print("Анимация атаки закончилась")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("has_health"):
		body.health -= damage
