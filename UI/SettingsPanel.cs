using Godot;
using System;

public partial class SettingsPanel : Control
{
	[Signal]
	public delegate void ClosedEventHandler();
	
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
