extends CheckBox

func _ready():
	#Connect signal
	toggled.connect(_on_mute_toggled)

#Mute audio
func _on_mute_toggled(is_muted: bool):
	var audio_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(audio_bus_idx, is_muted)
