using Godot;
using System;

public partial class SettingsPanel : Control
{
	[Signal]
	public delegate void ClosedEventHandler();
	
	private OptionButton _languageButton;

	public override void _Ready()
	{
		_languageButton = GetNode<OptionButton>("VBoxContainer/LanguageButton");
		
		_languageButton.Clear();
		_languageButton.AddItem("English", 0);
		_languageButton.AddItem("Suomi", 1);

		string currentLocale = TranslationServer.GetLocale();
		if (currentLocale.StartsWith("fi"))
		{
			_languageButton.Select(1);
		}
		else
		{
			_languageButton.Select(0);
		}
		
		_languageButton.ItemSelected += OnLanguageSelected;
	}
	private void OnLanguageSelected(long index)
	{
		if (index == 0)
		{
			TranslationServer.SetLocale("en");
		}
		else if (index == 1)
		{
			TranslationServer.SetLocale("fi");
		}
	}

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
	
	public void _on_back_btn_pressed()
	{
		this.Visible = false;

		EmitSignal(SignalName.Closed);
	}
}
