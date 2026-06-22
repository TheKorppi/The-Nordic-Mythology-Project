extends RigidBody3D

var speed = 5.0
var damage = 50.0

func _ready():
	%Fuse.start()

func _physics_process(delta: float) -> void:
	position += -transform.basis.z * speed * delta

# Pommi räjähtää kun ajastin pysähtyy
func _on_fuse_timeout():
	var targets_in_radius = %Explosion.get_overlapping_bodies()
	for target in targets_in_radius:
		if target.is_in_group("Player"):
			var rayParams = PhysicsRayQueryParameters3D.create(global_transform.origin, target.global_transform.origin)
			var result = get_world_3d().direct_space_state.intersect_ray(rayParams)
			
		if target.is_in_group("Props"):
			var source = self.global_transform.origin
			target.Prop_hit(source)
	
	queue_free()
