using Godot;

public partial class NetworkManager : Node
{
	private const int PORT = 7777;
	private const int MAX_PLAYERS = 4; 
	
	private ENetMultiplayerPeer _peer;

	public void HostGame()
	{
		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateServer(PORT, MAX_PLAYERS);
		
		if (error != Error.Ok)
		{
			GD.Print("Error creating server: " + error);
			return;
		}
		
		Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Server created successfully! Waiting for players...");
	}

	public void JoinGame(string ipAddress)
	{
		_peer = new ENetMultiplayerPeer();
		Error error = _peer.CreateClient(ipAddress, PORT);
		
		if (error != Error.Ok)
		{
			GD.Print("Error connecting to server: " + error);
			return;
		}

		Multiplayer.MultiplayerPeer = _peer;
		GD.Print("Connecting to server at: " + ipAddress);
	}
}
