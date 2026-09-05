extends Area3D

@onready var axe_swing: AnimationPlayer = %AnimationPlayer
@export var weapon_damage = 40.0

var enemies_in_area = []

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		enemies_in_area.append(body)

func _on_axe_swing_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"axe_swing":
			if !Input.is_action_pressed("primary_fire"):
				$Axe.monitoring = false
			print(str($Axe.monitoring))

func _on_axe_swing_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"axe_swing":
			if Input.is_action_pressed("primary_fire"):
				$Axe.monitoring = true
