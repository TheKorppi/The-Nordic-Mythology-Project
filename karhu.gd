extends CharacterBody3D

#@onready var animation = $AnimationPlayer
@onready var navigation = $NavigationAgent3D

const UPDATE_TIME = 0.2
const SPEED = 150
const SMOOTHING_FACTOR = 0.1

var target
var update_timer := 0.0

func _ready():
	target = PlayerManager.player

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
	move_and_slide()
	
