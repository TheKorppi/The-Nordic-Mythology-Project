extends CharacterBody3D

var speed = 9.0
var sprint_scalar = 2.0
var rotation_speed = 1.0
var health = 100.0

#@onready var stun_timer: Timer = %StunTimer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	PlayerManager.player = self

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		#TODO Primary action
		pass
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)	
		

func _input(event):
	if event is InputEventMouseMotion:
		# throw weapon
		pass

func _physics_process(delta):
	
	# Pelaajan liikkuminen
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
	
	# Pelaajahahmon kääntyminen
	
	if velocity.length_squared() > 0.01:
		var look_dir = Vector2(velocity.x, velocity.z)
		rotation.y = atan2(-look_dir.x, -look_dir.y)
	
	# Juoksu ja hyppy
	# Näiden pitää olla yllä olevan koodin alla!
	
	if Input.is_action_pressed("sprint"):
		velocity.x *= sprint_scalar
		velocity.z *= sprint_scalar
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0
		
	velocity.y -= 20.0 * delta
	
	move_and_slide()
	
	if Input.is_action_just_pressed("primary_fire"):
		throw_bomb()
	
func player_hit(damage):
	health -= damage
	if health < 0:
		health = 0

func throw_bomb():
	const FIRE_BOMB = preload("res://player/weapons/bomb/fire_bomb.tscn")
	var new_bomb = FIRE_BOMB.instantiate()
	%the_hand.add_child(new_bomb) 
	
	new_bomb.global_transform = %the_hand.global_transform
		
