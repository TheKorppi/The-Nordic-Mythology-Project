extends CharacterBody3D

<<<<<<< Updated upstream
var health = 100
=======
var speed = 9.0
var sprint_scalar = 2.0
var rotation_speed = 1.0
var health = 100.0
var is_swinging_weapon = false
>>>>>>> Stashed changes

@onready var axe_hitbox = %WeaponHitbox

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
<<<<<<< Updated upstream
	
func _physics_process(delta):
	var speed = 5.5
	var sprint_scalar = 2.0	
	var rotation_speed = 0.000000001
=======

func _physics_process(delta):
	
	player_movement(delta)
	move_and_slide()
	
	if Input.is_action_pressed("primary_fire") && not is_swinging_weapon:
		#throw_bomb()
		%axe_swing.play("axe_swing")
		is_swinging_weapon = true
	
func player_hit(damage):
	health -= damage
	if health < 0:
		health = 0

func throw_bomb():
	const FIRE_BOMB = preload("res://player/weapons/bomb/fire_bomb.tscn")
	var new_bomb = FIRE_BOMB.instantiate()
	%the_hand.add_child(new_bomb) 
	
	new_bomb.global_transform = %the_hand.global_transform
	
func _on_axe_swing_animation_finished(anim_name: StringName) -> void:
	if anim_name == "axe_swing":
		is_swinging_weapon = false
		#if !Input.is_action_pressed("primary_fire"):
		axe_hitbox.monitoring = false
	
func player_movement(delta):
	
	# WASD
	if Input.is_action_pressed("move_right"):
		velocity.x += 1.0
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1.0
	
	if Input.is_action_pressed("move_up"):
		velocity.z -= 1.0
	
	if Input.is_action_pressed("move_down"):
		velocity.z += 1.0
	
	# aivan hirveä ehtolause, mutta menkööt
	# pysäyttää pelaajan kun ei liikuta WASD-näppäimillä
	if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left") || Input.is_action_pressed("move_up") || Input.is_action_pressed("move_down"):
		velocity = velocity.normalized() * speed
	else:
		velocity.x = 0
		velocity.z = 0
>>>>>>> Stashed changes
	
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
