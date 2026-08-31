using Godot;

public partial class PauseMenu : CanvasLayer
{
	private Control _menuPanel;
	private Control _settingsPanel;
	private ColorRect _blurBackground;

	public override void _Ready()
	{
		_menuPanel = GetNode<Control>("MenuPanel");
		_settingsPanel = GetNode<Control>("SettingsPanel"); 
		_blurBackground = GetNode<ColorRect>("BlurBackground");
		
		_menuPanel.Visible = false;
		_blurBackground.Visible = false;
		
		if (_settingsPanel != null)
		{
			_settingsPanel.Visible = false;
		}
	}

	public override void _Input(InputEvent @event)
	{
		if (@event.IsActionPressed("ui_cancel"))
		{
			if (_settingsPanel != null && _settingsPanel.Visible)
			{
				_settingsPanel.Visible = false;
				_menuPanel.Visible = true;
				return;
			}

			_menuPanel.Visible = !_menuPanel.Visible;

			if (_menuPanel.Visible)
			{
				Input.MouseMode = Input.MouseModeEnum.Visible;
				_blurBackground.Visible = true;
			}
			else
			{
				Input.MouseMode = Input.MouseModeEnum.Captured;
				GetViewport().GuiReleaseFocus(); 
				_blurBackground.Visible = false;
			}
		}
	}

	public void _on_resume_btn_pressed()
	{
		_menuPanel.Visible = false;
		Input.MouseMode = Input.MouseModeEnum.Captured;
		_blurBackground.Visible = false;
	}

	public void _on_settings_btn_pressed()
	{
		_settingsPanel.Visible = true;
		_menuPanel.Visible = false; 
	}

	public void _on_disconnect_btn_pressed()
	{
		Input.MouseMode = Input.MouseModeEnum.Visible;

		NetworkManager netManager = GetNode<NetworkManager>("/root/NetworkManager");
		
		netManager.CallDeferred("Disconnect");

		GetTree().ChangeSceneToFile("res://UI/MainMenu.tscn");
	}
	
	public void _on_settings_panel_closed()
	{
		_menuPanel.Visible = true;
	}
}
