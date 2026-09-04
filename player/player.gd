extends CharacterBody3D

var speed = 9.0
var sprint_scalar = 2.0
var rotation_speed = 1.0
var health = 100.0
var is_swinging_weapon = false

@onready var axe_hitbox = %WeaponHitbox
@onready var axe_animation = %AxeAnimation
@onready var audio_listener = $AudioListener3D
@onready var WalkingStone: AudioStreamPlayer = $WalkingStone
@onready var animation_tree: AnimationTree = $AnimationTree

func _enter_tree():
	var authority_id = str(name).to_int()
	if authority_id == 0:
		authority_id = 1
	set_multiplayer_authority(authority_id)

func _ready():
	if is_multiplayer_authority():
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		audio_listener.make_current()
		
	PlayerManager.player = self

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE: return

	if event is InputEventMouseButton:
		#TODO Primary action
		pass

func _input(event):
	if event is InputEventMouseMotion:
		# throw weapon
		pass

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	player_movement(delta)
	move_and_slide()
	
	if Input.is_action_pressed("primary_fire") && not is_swinging_weapon:
		#throw_bomb() toteutaan eri nappiin, tai slottiin? mahdollisesti kirveen heitto
		axe_animation.play("axe_swing")
		is_swinging_weapon = true
		
func player_movement(delta):
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
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		velocity.y -= 20.0 * delta 
		move_and_slide()
		WalkingStone.stop()
		return
	
	# WASD-syöte
	var input_direction2D = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var direction = Vector3.ZERO
	var cam = get_viewport().get_camera_3d()

	if cam and input_direction2D != Vector2.ZERO:
		var cam_forward = -cam.global_transform.basis.z
		var cam_right = cam.global_transform.basis.x

		cam_forward.y = 0
		cam_right.y = 0
		cam_forward = cam_forward.normalized()
		cam_right = cam_right.normalized()

		direction = (cam_right * input_direction2D.x - cam_forward * input_direction2D.y).normalized()

	if direction != Vector3.ZERO:
		var target_angle = atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if is_on_floor() and not WalkingStone.playing:
			WalkingStone.play()
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
		if WalkingStone.playing:
			WalkingStone.stop()

	if Input.is_action_pressed("sprint"):
		velocity.x *= sprint_scalar
		velocity.z *= sprint_scalar

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 10.0
		WalkingStone.stop()
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	if not is_on_floor() and WalkingStone.playing:
		WalkingStone.stop()

	# Painovoima
	velocity.y -= 20.0 * delta
	
func _on_axe_swing_animation_finished(anim_name: StringName) -> void:
	if anim_name == "axe_swing":
		is_swinging_weapon = false
		#if !Input.is_action_pressed("primary_fire"):
		axe_hitbox.monitoring = false

func player_hit(damage):
	health -= damage
	if health < 0:
		health = 0
	
func throw_bomb():
	const FIRE_BOMB = preload("res://player/weapons/bomb/fire_bomb.tscn")
	var new_bomb = FIRE_BOMB.instantiate()
	%the_hand.add_child(new_bomb) 
	
	new_bomb.global_transform = %the_hand.global_transform
		
@rpc("any_peer", "call_local")
func teleport(new_pos: Vector3):
	global_position = new_pos
	velocity = Vector3.ZERO
	
	if not is_multiplayer_authority():
		return

	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("move_to_new_room"):

		var best_center = new_pos
		var closest_dist = 999999.0
		
		for center_node in get_tree().get_nodes_in_group("map_centers"):
			var d = new_pos.distance_to(center_node.global_position)
			if d < closest_dist:
				closest_dist = d
				best_center = center_node.global_position
				
		cam.move_to_new_room(best_center)
		
