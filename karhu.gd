extends CharacterBody3D

@onready var navigation = $NavigationAgent3D
@onready var anim_tree = %AnimationTree
@onready var enemy_hitbox : Area3D = $Karhu_Area3D
@onready var growl_sound = $GrowlSound
@onready var growl_timer = $GrowlTimer

var state_machine
const UPDATE_TIME = 0.2
const SPEED = 150
const SMOOTHING_FACTOR = 0.1
@export var attack_damage = 40.0

var knockback_velocity : Vector3 = Vector3.ZERO
var enemy_health = 200.0
var is_hurt = false

@export var player_path : NodePath
var attack_damage = 40.0
@onready var enemy_hitbox : Area3D = $Karhu_Area3D

var enemy_health = 200.0

var is_attacking = false
var targets_in_range = []

var target
var update_timer := 0.0

var next_pos
var dir
var current_facing
var new_dir

func _ready():
	target = PlayerManager.player
	state_machine = anim_tree.get("parameters/playback")

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

func set_target(pos = target.position):
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
		
	next_pos = navigation.get_next_path_position()
	dir = (next_pos - global_position).normalized()
	dir.y = 0.0
	
	if dir != Vector3.ZERO:
		var current_facing = -global_transform.basis.z
		var new_dir = current_facing.slerp(dir, SMOOTHING_FACTOR).normalized()
		look_at(global_position + new_dir, Vector3.UP)
	
	velocity = velocity.lerp(dir * speed * delta, SMOOTHING_FACTOR)
	velocity += knockback_velocity
	move_and_slide()

func damage_players():
	for body in targets_in_range:
		if body.is_in_group("Player"):
			body.take_damage(attack_damage)

func take_damage(damage):
	enemy_health -= damage
	#anim_tree.play("karhu_hurt")
	
	if enemy_health <= 0:
		# start death animation, then free queue in said animation script
		queue_free()

func _on_karhu_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and not targets_in_range.has(body):
		targets_in_range.append(body)
		# play attack animation

func _on_karhu_hitbox_body_exited(body: Node3D) -> void:
	if targets_in_range.has(body):
		targets_in_range.erase(body)

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"karhu_attack":
			damage_players()
			is_attacking = false
		"karhu_death":
			queue_free()

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"karhu_attack":
			is_attacking = true		

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
