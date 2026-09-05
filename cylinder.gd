extends MeshInstance3D
# Adjustable speed in radians per second (approx. 2.0 rotates about 1/3 of a full turn per second)
@export var rotation_speed: float = -0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Rotates the mesh around its local Y-axis (yaw)
	rotate_x(rotation_speed * delta)
