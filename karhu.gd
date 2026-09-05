extends CharacterBody3D

@onready var navigation = $NavigationAgent3D
@onready var animation = %Karhu_Animation
@onready var enemy_hitbox : Area3D = $Karhu_Area3D
@onready var growl_sound = $GrowlSound
@onready var growl_timer = $GrowlTimer

const UPDATE_TIME = 0.2
const SPEED = 150.0
const SMOOTHING_FACTOR = 0.1
@export var attack_damage = 40.0

var knockback_velocity : Vector3 = Vector3.ZERO
var enemy_health = 200.0
var is_hurt = false

var target
var update_timer := 0.0

func _ready():
	if is_multiplayer_authority():
		growl_timer.wait_time = randf_range(2.0, 10.0)
		growl_timer.start()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if !is_hurt:
		move_to_agent(delta)

func get_closest_player() -> Node3D:
	var players = get_tree().get_nodes_in_group("Player")
	var closest = null
	var min_dist = INF
	
	for p in players:
		var dist = global_position.distance_to(p.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = p
			
	return closest

func set_target(pos: Vector3):
	navigation.set_target_position(pos)
	
func move_to_agent(delta: float, speed: float = SPEED):
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		target = get_closest_player()
		if target != null:
			set_target(target.global_position)

	if target == null:
		return
			
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return
			
	if navigation.is_navigation_finished():
		return
		
	var next_pos = navigation.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	dir.y = 0.0
	
	if dir != Vector3.ZERO:
		var current_facing = -global_transform.basis.z
		var new_dir = current_facing.slerp(dir, SMOOTHING_FACTOR).normalized()
		look_at(global_position + new_dir, Vector3.UP)
	
	velocity = velocity.lerp(dir * speed * delta, SMOOTHING_FACTOR)
	velocity += knockback_velocity
	move_and_slide()
	
func get_hit(damage):
	if !is_hurt:
		enemy_health -= damage
		is_hurt = true
		animation.play("karhu_hurt")
	
	if enemy_health <= 0:
		defeat_enemy()

func defeat_enemy():
	queue_free()

func _on_karhu_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "karhu_hurt":
		is_hurt = false


func _on_growl_timer_timeout() -> void:
	if not is_multiplayer_authority():
		return
	growl_timer.wait_time = randf_range(5.0, 10.0)
	growl_timer.start()
	
	rpc("play_growl_sound")

@rpc("authority", "call_local", "unreliable")
func play_growl_sound():
	if enemy_health > 0:
		growl_sound.play()
