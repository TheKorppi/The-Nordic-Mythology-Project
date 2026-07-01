using Godot;
using System.Collections.Generic;


public partial class MainMenu : Control
{
	private Control _mainPanel;
	private Control _playPanel;
	private Control _characterPanel;
	private Control _friendlistPanel;
	private Control _settingsPanel;
	private Control _multiplayerPanel;
	private Control _joinPanel;
	private Control _lobbyPanel;
	private ItemList _playerList;
	private Button _startGameBtn;
	private NetworkManager _networkManager;

	private Stack<Control> _panelHistory = new Stack<Control>();
	private Control _currentPanel;

	public override void _Ready()
	{
		_mainPanel = GetNode<Control>("MainPanel");
		_playPanel = GetNode<Control>("PlayPanel");
		_characterPanel = GetNode<Control>("CharacterPanel");
		_friendlistPanel = GetNode<Control>("FriendlistPanel");
		_settingsPanel = GetNode<Control>("SettingsPanel");
		_multiplayerPanel = GetNode<Control>("MultiplayerPanel");
		_joinPanel = GetNode<Control>("JoinPanel");
		
		_lobbyPanel = GetNode<Control>("LobbyPanel");
		_playerList = GetNode<ItemList>("LobbyPanel/VBoxContainer/PlayerList");
		_startGameBtn = GetNode<Button>("LobbyPanel/VBoxContainer/StartGameBtn");

		_networkManager = GetNode<NetworkManager>("/root/NetworkManager");
		_networkManager.PlayerListChanged += UpdatePlayerList;

		_currentPanel = _mainPanel;
		ShowPanel(_mainPanel, addToHistory: false);
	}

	private void ShowPanel(Control panelToShow, bool addToHistory = true)
	{
		if (addToHistory && _currentPanel != null)
		{
			_panelHistory.Push(_currentPanel);
		}

		_mainPanel.Visible = false;
		_playPanel.Visible = false;
		_characterPanel.Visible = false;
		_friendlistPanel.Visible = false;
		_settingsPanel.Visible = false;
		_multiplayerPanel.Visible = false;
		_joinPanel.Visible = false;
		_lobbyPanel.Visible = false;

		panelToShow.Visible = true;
		_currentPanel = panelToShow;
	}

	public void _on_play_btn_pressed() { ShowPanel(_playPanel); }
	public void _on_character_btn_pressed() { ShowPanel(_characterPanel); }
	public void _on_friendlist_btn_pressed() { ShowPanel(_friendlistPanel); }
	public void _on_settings_btn_pressed() { ShowPanel(_settingsPanel); }
	public void _on_multiplayer_btn_pressed() { ShowPanel(_multiplayerPanel); }
	public void _on_exit_btn_pressed() { GetTree().Quit(); }
	
		public void _on_back_btn_pressed()
	{
		if (_panelHistory.Count > 0)
		{
			Control previousPanel = _panelHistory.Pop();
			ShowPanel(previousPanel, addToHistory: false);
		}
		else
		{
			ShowPanel(_mainPanel, addToHistory: false);
		}
	}

	public void _on_host_btn_pressed()
	{
		_networkManager.HostGame();
		ShowPanel(_lobbyPanel);
		_startGameBtn.Visible = true; 
	}

	public void _on_connect_btn_pressed()
	{
		LineEdit ipInput = GetNode<LineEdit>("JoinPanel/IpInput");
		_networkManager.JoinGame(ipInput.Text);
		ShowPanel(_lobbyPanel);
		_startGameBtn.Visible = false;
	}
	
	public void _on_start_game_btn_pressed()
	{
		_networkManager.StartGame();
	}

	private void UpdatePlayerList()
	{
		_playerList.Clear();
		foreach (long playerId in _networkManager.Players)
		{
			if (playerId == 1)
				_playerList.AddItem("Player " + playerId + " (Host)");
			else
				_playerList.AddItem("Player " + playerId);
		}
	}
	
	public void _on_join_btn_pressed()
	{
		ShowPanel(_joinPanel);
	}
	
	public void _on_singleplayer_btn_pressed()
	{
		GetTree().ChangeSceneToFile("res://Game.tscn");
	}

	// SETTINGS
	public void _on_volume_slider_value_changed(float value)
	{
		int busIndex = AudioServer.GetBusIndex("Master");
		AudioServer.SetBusVolumeDb(busIndex, Mathf.LinearToDb(value));
	}

	public void _on_fullscreen_toggle_toggled(bool isToggled)
	{
		if (isToggled)
			DisplayServer.WindowSetMode(DisplayServer.WindowMode.Fullscreen);
		else
			DisplayServer.WindowSetMode(DisplayServer.WindowMode.Windowed);
	}
}
