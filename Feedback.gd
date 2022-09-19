extends Control

var cardName := ""
var cardDesc := ""
var data 
func _ready():
	var file = File.new()
	file.open("res://apiKeys.json", File.READ)
	data = parse_json(file.get_as_text())

func _on_Submit_pressed():
	cardName = $ColorRect/VBoxContainer/LineEdit.text
	cardDesc = get_parent().ownCustomization.name + " - " + $ColorRect/VBoxContainer/TextEdit.text
	
	if " " in cardName:
		cardName = cardName.replace(" ", "%20") 
	if " " in cardDesc:
		cardDesc = cardDesc.replace(" ", "%20")
	if "\n" in cardDesc: 
		cardDesc = cardDesc.replace("\n", "%0D%0A")
	$HTTPRequest.request("https://api.trello.com/1/cards?idList="+data.idList+"&key="+data.apiKey+"&token="+data.apiToken+"&name="+cardName+"&desc="+cardDesc, [], false, HTTPClient.METHOD_POST)
	queue_free()

func _on_Cancel_pressed():
	queue_free()
