extends Control

var controls := ["accelerate", "break", "left", "right", "pause"]

var selecting:= []

var x

func _ready():
	
	for controlName in controls:
		var keyName: String = InputMap.get_action_list(controlName)[0].as_text()
		var hbox := HBoxContainer.new()
		hbox.alignment = 1
		$VBoxContainer.add_child(hbox)
		hbox.add_constant_override("separation", 200)

		var label := Label.new()
		label.text = controlName
		label.rect_min_size.x = 400
		label.align = 1
		hbox.add_child(label)

		var button := Button.new()
		button.text = keyName
		button.rect_min_size.x = 400
		button.connect("pressed", self, "buttonPress", [button, controlName])
		hbox.add_child(button)


func buttonPress(button: Button, controlName:String):
	if selecting != []:
		return
	selecting = [button, controlName]
	button.text = "Press any key"


func _input(event: InputEvent):
	if event.as_text().begins_with("InputEventMouse"):
		return
	if selecting == []:
		return
	if event.as_text() == "Meta+":  #Win key
		return
	var multi := [16777237, 16777238, 16777240] #Shift, Control, Alt
	selecting[0].text = event.as_text()
	if !multi.has(event.get_scancode()):
		InputMap.action_erase_event(selecting[1], InputMap.get_action_list(selecting[1])[0])
		InputMap.action_add_event(selecting[1], event)
		selecting = []
	else:
		selecting[0].text += "+..."
