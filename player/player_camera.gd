extends Camera3D

@export var mi : MeshInstance2D

func _physics_process(delta: float) -> void:
	
	var cam := %Player_Camera
	# Hiiren sijainti 2D yksikköinä
	var mouse_pos := get_viewport().get_mouse_position()
	
	var rayStart :Vector3 = cam.project_ray_origin(mouse_pos)
	var direction :Vector3 = cam.project_ray_normal(mouse_pos)
	
	var plane := Plane(Vector3.UP)
	
	var intersection = plane.intersects_ray(rayStart, direction)
	
	if intersection:
		mi.global_position.x = intersection.x
		mi.global_position.y = intersection.y
	
	if Input.is_action_just_pressed("right_click"):
		# oikeaa hiirtä painamalla voi kääntää kameran sijaintia 
		# pelaajaan nähden
		#TODO
		pass
		
	if Input.is_action_just_pressed("mouse3"):
		# palauttaa kameran alkusijaintiin
		#TODO
		pass
