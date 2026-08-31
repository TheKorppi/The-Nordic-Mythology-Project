extends CharacterBody3D

#@onready var animation = $AnimationPlayer
@onready var navigation = $NavigationAgent3D

@onready var animation = %Karhu_Animation

const UPDATE_TIME = 0.2
const SPEED = 150
const SMOOTHING_FACTOR = 0.1
@export var attack_damage = 40.0
@onready var enemy_hitbox : Area3D = $Karhu_Area3D
var knockback_velocity : Vector3 = Vector3.ZERO

var enemy_health = 200.0
var is_hurt = false


const UPDATE_TIME = 0.2
const SPEED = 150.0
const SMOOTHING_FACTOR = 0.1


var target
var update_timer := 0.0


func _ready():
	target = PlayerManager.player

func _physics_process(delta: float) -> void:
	if !is_hurt:
		move_to_agent(delta)

func set_target(pos = target.position):
	navigation.set_target_position(pos)
	
func move_to_agent(delta: float, speed: float = SPEED):
	
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		if target:
			set_target(target.position)
			
	if !is_on_floor():
			velocity += get_gravity() * delta
			move_and_slide()
			return

func _physics_process(delta: float) -> void:
	move_to_agent(delta)

func set_target(pos: Vector3):
	navigation.set_target_position(pos)
	
func move_to_agent(delta: float, speed: float = SPEED):
	if target == null:
		target = PlayerManager.player
		if target == null:
			return

	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		set_target(target.global_position)
			
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		return

			
	if navigation.is_navigation_finished():
		return
		
	var next_pos = navigation.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	dir.y = 0.0
	

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
	
	# sound
	if enemy_health <= 0:
		defeat_enemy()

func defeat_enemy():
	#defeat animation here
	queue_free()
	

func _on_karhu_animation_animation_finished(anim_name: StringName) -> void:
		if anim_name == "karhu_hurt":
			is_hurt = false

	if dir != Vector3.ZERO:
		var current_facing = -global_transform.basis.z
		var new_dir = current_facing.slerp(dir, SMOOTHING_FACTOR).normalized()
		look_at(global_position + new_dir, Vector3.UP)
		
		velocity = velocity.lerp(dir * speed * delta, SMOOTHING_FACTOR)
		

