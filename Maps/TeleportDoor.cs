using Godot;

public partial class TeleportDoor : Area3D
{
	public Marker3D SpawnPoint;
	public TeleportDoor TargetDoor;

	public override void _Ready()
	{
		SpawnPoint = GetNode<Marker3D>("SpawnPoint");
		BodyEntered += OnBodyEntered;
	}

	private void OnBodyEntered(Node3D body)
	{
		if (body.IsInGroup("Player") && Multiplayer.IsServer())
		{
			if (TargetDoor != null && TargetDoor.SpawnPoint != null)
			{
				body.Rpc("teleport", TargetDoor.SpawnPoint.GlobalPosition);
			}
		}
	}

	public Vector2I GetGlobalGridDirection(float roomRotationDegrees)
	{
		Vector3 localOutward = -Transform.Basis.Z.Normalized();

		float rad = Mathf.DegToRad(roomRotationDegrees);
		Vector3 globalOutward = localOutward.Rotated(Vector3.Up, rad);

		int x = Mathf.RoundToInt(globalOutward.X);
		int z = Mathf.RoundToInt(globalOutward.Z);

		return new Vector2I(x, z);
	}
}
