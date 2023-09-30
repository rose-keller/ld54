extends Panel

onready var content_label = $ContentLabel
onready var left_name_panel = $LeftNamePanel
onready var right_name_panel = $RightNamePanel

var speakers = []
var last_speaker

func show_line(content, speaker):
	visible = true
	
	content_label.text = content
	
	if speaker:
		last_speaker = speaker
		if not speaker in speakers:
			speakers.append(speaker)
	else:
		speaker = last_speaker
	
	left_name_panel.visible = false
	right_name_panel.visible = false
	
	if speaker:
		var name_panel = right_name_panel if speakers.find(speaker) % 2 else left_name_panel
		name_panel.visible = true
		name_panel.get_node("Label").text = speaker


func end_dialogue():
	visible = false
