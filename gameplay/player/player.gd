extends CharacterBody2D

var speed: float = 0
var end_speed: float = 200
var acceleration: float = 15
var deceleration: float = 25

func _ready() -> void:
	$EscMenu.visible = false
	$MobileControl.visible = false
	if OS.get_name() == "Android":
		$MobileControl.visible = true
	
func _physics_process(_delta: float) -> void:
	await movement(get_direct())
	await change_texture(get_direct())

func _input(_event):
	if Input.is_action_pressed("Esc"):
		$EscMenu.visible = true
		get_tree().paused = true

func get_direct():
	var direct = Vector2.ZERO
	direct = Input.get_vector("Left", "Right", "Up", "Down")
	direct = direct.normalized()
	
	return direct

func movement(direct):
	if direct != Vector2.ZERO:
		speed = min(speed + acceleration, end_speed)
		velocity = direct * speed
	else:
		speed = max(speed - deceleration, 0)
		velocity = velocity.normalized() * speed if velocity.length() > 0 else Vector2.ZERO

	move_and_slide()

func change_texture(direct):
	if direct == Vector2.ZERO:
		$Skin.stop()
		$Skin.frame = 0
		$Skin.frame_progress = 1
	else: $Skin.speed_scale = speed * .01
	if direct.y < 0:
		if !$Skin.is_playing() or ($Skin.animation != "up_walk" and $Skin.is_playing()):
			$Skin.play("up_walk")
	elif direct.y > 0:
		if !$Skin.is_playing() or ($Skin.animation != "down_walk" and $Skin.is_playing()):
			$Skin.play("down_walk")
	if direct.x > .8:
			if !$Skin.is_playing() or ($Skin.animation != "right_walk" and $Skin.is_playing()):
				$Skin.play("right_walk")
	elif direct.x < -.8:
		if !$Skin.is_playing() or ($Skin.animation != "left_walk" and $Skin.is_playing()):
			$Skin.play("left_walk")
