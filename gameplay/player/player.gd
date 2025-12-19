extends CharacterBody2D

func _ready() -> void:
	match OS.get_name():
		"Android":
			$MobileControl.visible = true
		"Windows":
			$MobileControl.visible = false
	
func _physics_process(_delta: float) -> void:
	await movement(get_direct())
	await change_texture(get_direct())

func _input(_event):
	if Input.is_action_pressed("Esc"):
		$EscMenu.visible = true
		get_tree().paused = true

func get_direct():
	#Получаем вектор направления
	var direct = Vector2.ZERO
	direct = Input.get_vector("Left", "Right", "Up", "Down")
	direct = direct.normalized()
	
	#Отладка
	#print(direct)
	return direct

func movement(direct):
	#Базовая скорость персонажа
	var speed: float = 800
	#Перемещение
	velocity = direct * speed
	move_and_slide()

func change_texture(direct):
	$Texture.texture.atlas = load("res://assets/player/down_static.png")
	if direct.x > 0:
		$Texture.texture.atlas = load("res://assets/player/right_static.png")
	elif direct.x < 0:
		$Texture.texture.atlas = load("res://assets/player/left_static.png")
	if direct.y > 0:
		$Texture.texture.atlas = load("res://assets/player/down_static.png")
	elif direct.y < 0:
		$Texture.texture.atlas = load("res://assets/player/up_static.png")
