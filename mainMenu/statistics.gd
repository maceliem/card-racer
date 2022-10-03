extends Control
tool

func _ready():
	for statisticsName in Global.statistics.keys():
		var value:int = Global.statistics[statisticsName]

		var title := Label.new()
		title.text = statisticsName
		title.align = 0
		$background/content/HBoxContainer/Names.add_child(title)

		var valueText := Label.new()
		valueText.text = str(value)
		valueText.align = 1
		$background/content/HBoxContainer/Values.add_child(valueText)


func _on_Button_pressed():
	queue_free()
