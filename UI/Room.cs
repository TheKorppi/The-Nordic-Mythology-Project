using Godot;
using System.Collections.Generic;

public partial class Room : Node3D
{
	public List<TeleportDoor> Doors = new List<TeleportDoor>();

	public override void _Ready()
	{
		foreach (Node child in GetChildren())
		{
			if (child is TeleportDoor door)
			{
				Doors.Add(door);
			}
		}
	}
}
