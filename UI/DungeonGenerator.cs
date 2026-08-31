using Godot;
using System.Collections.Generic;

public partial class DungeonGenerator : Node3D
{
	[Export] public float RoomSpacing = 200.0f;
	[Export] public int MaxRooms = 15;
	[Export] public Godot.Collections.Array<PackedScene> RoomScenes { get; set; } = new Godot.Collections.Array<PackedScene>();

	private Node3D _mapContainer;
	private MultiplayerSpawner _spawner;
	private RandomNumberGenerator _rng = new RandomNumberGenerator();

	private Dictionary<Vector2I, Room> _spawnedRooms = new Dictionary<Vector2I, Room>();
	
	private List<PendingDoor> _openEnds = new List<PendingDoor>();

	private class PendingDoor
	{
		public Vector2I RoomPos;
		public TeleportDoor Door;
		public Vector2I Direction;
		public PackedScene SourceScene;
	}

	public override void _Ready()
	{
		_mapContainer = new Node3D();
		_mapContainer.Name = "MapContainer";
		AddChild(_mapContainer);

		_spawner = new MultiplayerSpawner();
		_spawner.Name = "RoomSpawner";
		AddChild(_spawner);
		_spawner.SpawnPath = _mapContainer.GetPath();

		foreach (var scene in RoomScenes)
		{
			_spawner.AddSpawnableScene(scene.ResourcePath);
		}

		if (Multiplayer.IsServer())
		{
			_rng.Randomize();
			CallDeferred(nameof(GenerateDungeon));
		}
	}

	private void GenerateDungeon()
	{
		if (RoomScenes.Count == 0) return;

		SpawnRoom(Vector2I.Zero, RoomScenes[0], 0);

		int failsafe = 0;
		while (_openEnds.Count > 0 && _spawnedRooms.Count < MaxRooms && failsafe < 1000)
		{
			failsafe++;
			
			int doorIndex = _rng.RandiRange(0, _openEnds.Count - 1);
			PendingDoor pending = _openEnds[doorIndex];
			_openEnds.RemoveAt(doorIndex);

			Vector2I newRoomPos = pending.RoomPos + pending.Direction;

			if (_spawnedRooms.ContainsKey(newRoomPos))
			{
				TryConnectDoors(pending.Door, pending.Direction, _spawnedRooms[newRoomPos]);
				continue;
			}

			Vector2I requiredDir = new Vector2I(-pending.Direction.X, -pending.Direction.Y);
			bool roomPlaced = false;
			
			for(int attempts = 0; attempts < 20; attempts++)
			{
				PackedScene testScene = RoomScenes[_rng.RandiRange(0, RoomScenes.Count - 1)];

				if (RoomScenes.Count > 1 && testScene == pending.SourceScene)
				{
					continue; 
				}

				Room testRoom = testScene.Instantiate<Room>();
				
				for (int rot = 0; rot < 4; rot++)
				{
					float rotDegrees = rot * 90.0f;
					bool foundMatch = false;

					foreach (Node child in testRoom.GetChildren())
					{
						if (child is TeleportDoor d && d.GetGlobalGridDirection(rotDegrees) == requiredDir)
						{
							foundMatch = true;
							break;
						}
					}

					if (foundMatch)
					{
						testRoom.QueueFree(); 
						SpawnRoom(newRoomPos, testScene, rotDegrees); 
						TryConnectDoors(pending.Door, pending.Direction, _spawnedRooms[newRoomPos]);
						roomPlaced = true;
						break;
					}
				}

				if (roomPlaced) break;
				else testRoom.QueueFree();
			}
		}

		CleanupUnconnectedDoors();
	}

	private void SpawnRoom(Vector2I pos, PackedScene scene, float rotationDegrees)
	{
		Room newRoom = scene.Instantiate<Room>();
		newRoom.Name = $"Room_{pos.X}_{pos.Y}";
		newRoom.Position = new Vector3(pos.X * RoomSpacing, 0, pos.Y * RoomSpacing);
		newRoom.RotationDegrees = new Vector3(0, rotationDegrees, 0);

		_mapContainer.AddChild(newRoom);
		_spawnedRooms[pos] = newRoom;

		foreach (TeleportDoor door in newRoom.Doors)
		{
			_openEnds.Add(new PendingDoor {
				RoomPos = pos,
				Door = door,
				Direction = door.GetGlobalGridDirection(rotationDegrees),
				SourceScene = scene
			});
		}
	}

	private void TryConnectDoors(TeleportDoor doorA, Vector2I dirFromAToB, Room roomB)
	{
		Vector2I requiredDirB = new Vector2I(-dirFromAToB.X, -dirFromAToB.Y);
		
		foreach (TeleportDoor doorB in roomB.Doors)
		{
			float rotB = roomB.RotationDegrees.Y;
			if (doorB.GetGlobalGridDirection(rotB) == requiredDirB && doorB.TargetDoor == null)
			{
				doorA.TargetDoor = doorB;
				doorB.TargetDoor = doorA;
				
				for (int i = _openEnds.Count - 1; i >= 0; i--) {
					if (_openEnds[i].Door == doorB) _openEnds.RemoveAt(i);
				}
				break;
			}
		}
	}

	private void CleanupUnconnectedDoors()
	{
		foreach (var kvp in _spawnedRooms)
		{
			foreach (TeleportDoor door in kvp.Value.Doors)
			{
				if (door.TargetDoor == null)
				{
					door.QueueFree();
				}
			}
		}
	}
}
