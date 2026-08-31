extends Camera3D

@export var map_center: Vector3 = Vector3(0, 0, 0)
@export var radius: float = 17.0
@export var height: float = 15.0
@export var rotation_speed: float = 2.5

var current_angle: float = 0.0
var actual_center: Vector3 = Vector3.ZERO

func _ready() -> void:
	fov = 70.0
	actual_center = map_center
	
	var offset_x = sin(current_angle) * radius
	var offset_z = cos(current_angle) * radius
	global_position = actual_center + Vector3(offset_x, height, offset_z)
	look_at(actual_center, Vector3.UP)
	make_current()

func _physics_process(delta: float) -> void:
	actual_center = actual_center.lerp(map_center, 4.0 * delta)

	var rot_input = Input.get_axis("ui_left", "ui_right")
	current_angle += rot_input * rotation_speed * delta

	var offset_x = sin(current_angle) * radius
	var offset_z = cos(current_angle) * radius

	var target_pos = actual_center + Vector3(offset_x, height, offset_z)
	global_position = global_position.lerp(target_pos, 10.0 * delta)
	look_at(actual_center, Vector3.UP)

func move_to_new_room(new_pos: Vector3) -> void:
	map_center = new_pos
