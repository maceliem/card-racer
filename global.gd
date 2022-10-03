extends Node

signal instance_player(id)
signal toggle_network_setup(toggle)

var main: Main

var player: Player

var statistics := {
	"Coins collected:": 0,
	"Rubies collected:": 0,
	"1st place:": 0,
	"2nd place:": 0,
	"3rd place:": 0,
	"Laps finished:":0
}

var statsFile = "user://cardRacerStats.save"


func _saveGame():
	var saveData := statistics
	var file = File.new()
	file.open(statsFile, File.WRITE)
	file.store_var(saveData)
	file.close()


func _loadGame():
	var saveData
	var file = File.new()
	if file.file_exists(statsFile):
		file.open(statsFile, File.READ)
		saveData = file.get_var()
		file.close()

		for key in saveData.keys():
			statsFile[key] = saveData[key]
