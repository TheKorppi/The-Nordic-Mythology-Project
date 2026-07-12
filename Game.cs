using Godot;

public partial class Game : Node3D
{
	private PackedScene _playerScene = GD.Load<PackedScene>("res://player/player.tscn");

	public override void _Ready()
	{
		if (Multiplayer.IsServer())
		{
			Node3D playersContainer = GetNode<Node3D>("Players");
			NetworkManager networkManager = GetNode<NetworkManager>("/root/NetworkManager");

			foreach (long id in networkManager.Players)
			{
				Node3D currentPlayer = _playerScene.Instantiate<Node3D>();
				currentPlayer.Name = id.ToString();
				currentPlayer.Position = new Vector3(0, 5, id == 1 ? 0 : 2); 
				playersContainer.AddChild(currentPlayer);
			}
		}
	}
}
