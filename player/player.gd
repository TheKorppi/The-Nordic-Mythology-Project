extends CharacterBody3D

var health = 100

#@onready var stun_timer: Timer = %StunTimer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		#TODO Primary action
		pass
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
		
	
func _physics_process(delta):
	var speed = 5.5
	var sprint_scalar = 2.0	
	var rotation_speed = 0.000000001
	
	# Pelaajahahmon kääntyminen
	
	if velocity.length_squared() > 0.01:
		var look_dir = Vector2(velocity.x, velocity.z)
		rotation.y = atan2(-look_dir.x, -look_dir.y)
	
	# Pelaajan liikkuminen

	# Juoksu
	
	if Input.is_action_just_pressed("sprint"):
		velocity.x *= sprint_scalar
		velocity.z *= sprint_scalar
	
	# WASD
	
	var input_direction2D = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
		)

		
	var input_direction3D = Vector3(
		input_direction2D.x, 0.0, input_direction2D.y
	)
	
	if input_direction3D != Vector3.ZERO:
		var target_angle = atan2(-input_direction3D.x, -input_direction3D.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)
		velocity.x = input_direction3D.x * speed
		velocity.z = input_direction3D.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	
	# Painovoima
	velocity.y -= 20.0 * delta
	
	move_and_slide()
	
	if Input.is_action_just_pressed("primary_fire"):
		throw_bomb()
	
func player_hit(damage):
	health -= damage
	if health < 0:
		health = 0

func throw_bomb():
	const FIRE_BOMB = preload("res://player/fire_bomb.tscn")
	var new_bomb = FIRE_BOMB.instantiate()
	%the_hand.add_child(new_bomb) 
	
	new_bomb.global_transform = %the_hand.global_transform
		
