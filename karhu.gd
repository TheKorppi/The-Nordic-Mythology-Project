extends CharacterBody3D

@onready var navigation = $NavigationAgent3D
@onready var anim_tree = %AnimationTree

var state_machine
const UPDATE_TIME = 0.2
const SPEED = 150
const SMOOTHING_FACTOR = 0.1

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

func _physics_process(delta: float) -> void:
	move_to_agent(delta)

func set_target(pos = target.position):
	navigation.set_target_position(pos)
	
func move_to_agent(delta: float, speed: float = SPEED):
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		if target:
			set_target(target.position)
	
	match state_machine.get_current_node():
		"Idle":
			anim_tree.set("parameters/conditions/Run", true)
		"Walk":
			
			if !is_on_floor():
				velocity += get_gravity() * delta
				
				next_pos = navigation.get_next_path_position()
				
			dir = (next_pos - global_position).normalized()
			dir.y = 0.0
	
			current_facing = -global_transform.basis.z
			new_dir = current_facing.slerp(dir, SMOOTHING_FACTOR).normalized()
			look_at(global_position + new_dir, Vector3.UP)
	
			velocity = velocity.lerp(dir * speed * delta, SMOOTHING_FACTOR)
			move_and_slide()
			
		"Attack":
			anim_tree.set("parameters/conditions/Run", !targets_in_range)
	
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
			
