using Godot;

public partial class Game : Node3D
{
	private PackedScene _playerScene = GD.Load<PackedScene>("res://player/player.tscn");
	private NetworkManager _networkManager;
	
	private bool _isListeningPeerDisconnect = false;
	private bool _isListeningConnectionLost = false;

	public override void _Ready()
	{
		Node3D playersContainer = GetNode<Node3D>("Players");
		_networkManager = GetNode<NetworkManager>("/root/NetworkManager");

		if (_networkManager.Players != null && _networkManager.Players.Count > 0)
		{
			if (Multiplayer.IsServer())
			{
				foreach (long id in _networkManager.Players)
				{
					SpawnPlayer(id, playersContainer);
				}
				
				Multiplayer.PeerDisconnected += RemovePlayer;
				_isListeningPeerDisconnect = true;
			}
			
			_networkManager.ConnectionLost += OnConnectionLost;
			_isListeningConnectionLost = true;
		}
		else
		{
			SpawnPlayer(1, playersContainer);
		}
	}

	public override void _ExitTree()
	{
		if (_isListeningPeerDisconnect)
		{
			Multiplayer.PeerDisconnected -= RemovePlayer;
		}
		
		if (_networkManager != null && _isListeningConnectionLost)
		{
			_networkManager.ConnectionLost -= OnConnectionLost;
		}
	}

	private void RemovePlayer(long id)
	{
		Node3D playersContainer = GetNode<Node3D>("Players");
		Node playerNode = playersContainer.GetNodeOrNull(id.ToString());
		
		if (playerNode != null)
		{
			playerNode.QueueFree();
		}
	}

	private void OnConnectionLost()
	{
		Input.MouseMode = Input.MouseModeEnum.Visible;
		GetTree().ChangeSceneToFile("res://UI/MainMenu.tscn");
	}

	private void SpawnPlayer(long id, Node3D container)
	{
		Node3D currentPlayer = _playerScene.Instantiate<Node3D>();
		currentPlayer.Name = id.ToString();
		currentPlayer.Position = new Vector3(0, 5, id == 1 ? 0 : 2); 
		
		container.AddChild(currentPlayer);
	}
}
