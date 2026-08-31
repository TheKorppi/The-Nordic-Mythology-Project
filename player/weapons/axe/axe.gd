extends Area3D

@onready var axe_swing: AnimationPlayer = %AnimationPlayer
@export var weapon_damage = 40.0

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.get_hit(weapon_damage)
		print("enemy hit")
