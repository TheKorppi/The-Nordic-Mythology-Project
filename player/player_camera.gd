extends Camera3D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		# oikeaa hiirtä painamalla voi kääntää kameran sijaintia 
		# pelaajaan nähden
		#TODO
		pass
		
	if Input.is_action_just_pressed("mouse3"):
		# palauttaa kameran alkusijaintiin
		#TODO
		pass
