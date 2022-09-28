tool
extends Button
class_name Card

export(Texture) var image
export(String) var cardName
export(int, "Common", "Rare", "Epic") var rarity
export(int, 0, 100) var price
export(String, MULTILINE) var description

var shop: Control

var height := 384
var ratio := 1.4
var rarityName := ["common", "rare", "epic"]

var modifiers := {
	"rubyChance": 0,
	"offroad": 0.0,
	"maxRPM": 0,
	"maxTorque": 0,
	"headstart": 0,
	"disableBreaks": false,
	"handelingSpeed": 0,
	"handelingAmount": 0.0,
	"scale": 0.0,
	"mass": 0
}


func _ready():
	shop = Global.main.get_node("gameInterface/TabContainer/Shop")
	connect("pressed", self, "_on_card_pressed")
	rect_size = Vector2(height / ratio, height)
	rect_min_size = Vector2(height / ratio, height)
	theme = load("res://assets/themes/cardTheme.tres")
	theme_type_variation = rarityName[rarity] + "Card"
	#container of card elements
	var vbox := VBoxContainer.new()
	vbox.rect_size = rect_size
	vbox.rect_min_size = rect_size
	vbox.alignment = 0
	add_child(vbox)

	#name of card
	var title := Label.new()
	title.text = cardName
	title.align = 1
	title.mouse_filter = 1
	title.theme_type_variation = rarityName[rarity] + "Label"
	vbox.add_child(title)

	#icon
	var textCenter := CenterContainer.new()
	textCenter.mouse_filter = 1
	vbox.add_child(textCenter)
	var texture := TextureRect.new()
	texture.texture = image
	texture.mouse_filter = 1
	textCenter.add_child(texture)

	#description of card
	var bottomText := Label.new()
	bottomText.text = description
	bottomText.mouse_filter = 1
	bottomText.autowrap = true
	bottomText.theme_type_variation = "description"
	vbox.add_child(bottomText)

	#price indicator
	var priceLabel := Label.new()
	priceLabel.text = str(price)
	priceLabel.mouse_filter = 1
	add_child(priceLabel)
	priceLabel.rect_position = Vector2(rect_size.x - priceLabel.rect_size.x - 4, title.rect_size.y)

	#if get_parent().name == "Shop":
	connect("tree_exited", self, "_tree_exited")


#group modifiers
func _get(property: String):
	for key in modifiers.keys():
		if property == "modifiers/" + key:
			return modifiers[key]


func _set(property: String, value) -> bool:
	for key in modifiers.keys():
		if property == "modifiers/" + key:
			modifiers[key] = value
	return true


func _get_property_list() -> Array:
	var props := []
	for key in modifiers.keys():
		props.append({"name": "modifiers/" + key, "type": typeof(modifiers[key])})
	return props


func _on_card_pressed():
	if get_tree().current_scene.name != "main":
		return
	if Global.player.coins >= price:
		Global.player.coins -= price

		shop.get_node("coinCounter/Label").text = str(Global.player.coins)

		if modifiers.rubyChance > 0:
			if !Global.main.coinChance.keys().has("ruby"):
				Global.main.coinChance.ruby = modifiers.rubyChance
			else:
				Global.main.coinChance.ruby += modifiers.rubyChance

		if modifiers.headstart != 0:
			Global.player.countdownTime += modifiers.headstart
			if Global.player.countdownTime < 0:
				Global.player.countdownTime = 0

		if modifiers.scale != 0:
			Global.player.scale *= modifiers.scale

		if modifiers.disableBreaks:
			Global.player.workingBreaks = false
		#Player modifiers, that doesn't need special treatment
		var simplePlayerModifiers := [
			"offroad", "maxRPM", "maxTorque", "handelingSpeed", "handelingAmount", "mass"
		]
		for type in simplePlayerModifiers:
			if modifiers[type] != 0:
				Global.player[type] += modifiers[type]
		queue_free()


func _tree_exited():
	shop.refill()
