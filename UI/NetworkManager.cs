using Godot;
using System.Collections.Generic;

public partial class NetworkManager : Node
{
	private const int PORT = 7777;
	private const int MAX_PLAYERS = 4; 
	private ENetMultiplayerPeer _peer;

	public List<long> Players = new List<long>();

	[Signal]
	public delegate void PlayerListChangedEventHandler();

	public override void _Ready()
	{
		Multiplayer.PeerConnected += OnPeerConnected;
		Multiplayer.PeerDisconnected += OnPeerDisconnected;
		
		Multiplayer.ConnectedToServer += OnConnectedToServer; 
	}

	private void OnConnectedToServer()
	{
		long myId = Multiplayer.GetUniqueId(); 
		GD.Print("Onnistunut yhteys! Oma ID on: " + myId);
		
		Players.Add(myId);
		EmitSignal(SignalName.PlayerListChanged);
	}

	public void HostGame()
	{
		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateServer(PORT, MAX_PLAYERS);
		
		if (error != Error.Ok) return;
		Multiplayer.MultiplayerPeer = _peer;
		
		Players.Clear();
		Players.Add(1);
		EmitSignal(SignalName.PlayerListChanged);
	}

	public void JoinGame(string ipAddress)
	{
		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateClient(ipAddress, PORT);
		if (error != Error.Ok) return;
		
		Multiplayer.MultiplayerPeer = _peer;
	}

	private void OnPeerConnected(long id)
	{
		GD.Print("Player joined! ID: " + id);
		Players.Add(id);
		EmitSignal(SignalName.PlayerListChanged);
	}

	private void OnPeerDisconnected(long id)
	{
		Players.Remove(id);
		EmitSignal(SignalName.PlayerListChanged);
	}

	public void StartGame()
	{
		if (Multiplayer.IsServer())
		{
			Rpc(nameof(LoadGameScene));
		}
	}

	[Rpc(MultiplayerApi.RpcMode.Authority, CallLocal = true)]
	private void LoadGameScene()
	{
		GetTree().ChangeSceneToFile("res://Game.tscn");
	}
}
