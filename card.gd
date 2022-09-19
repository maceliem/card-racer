tool
extends Button
class_name Card

export(Texture) var image 
export(String) var cardName
export(int, "Common", "Rare", "Epic") var rarity
export(int, 0, 100) var price
export(String) var description

var height := 256
var ratio := 1.4
var rarityName := ["common", "rare", "epic"]

var modifiers := {
	"rubyChance": 0,
	"shiny": false
}

func _ready():
	connect("pressed", self, "_on_card_pressed")
	rect_min_size = Vector2(height / ratio, height)
	theme = load("res://assets/themes/cardTheme.tres")
	theme_type_variation = rarityName[rarity]+"Card"
	#container of card elements
	var vbox := VBoxContainer.new()
	vbox.rect_size = rect_size
	vbox.alignment = 0
	add_child(vbox)

	#name of card
	var title := Label.new()
	title.text = cardName
	title.align = 1
	title.mouse_filter = 1
	title.theme_type_variation = rarityName[rarity]+"Label"
	vbox.add_child(title)

	#icon
	var center := CenterContainer.new()
	center.mouse_filter = 1
	vbox.add_child(center)
	var texture := TextureRect.new()
	texture.texture = image
	texture.mouse_filter = 1
	center.add_child(texture)

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
	
	

#group modifiers
func _get(property:String):
	for key in modifiers.keys():
		if property == "modifiers/"+key:
			return modifiers[key]

func _set(property:String, value) -> bool:
	for key in modifiers.keys():
		if property == "modifiers/"+key:
			modifiers[key] = value
	return true
		
func _get_property_list() -> Array:
	var props := []
	for key in modifiers.keys():
		props.append({
		"name": "modifiers/" + key,
		"type": typeof(modifiers[key])
		})
	return props


func _on_card_pressed():
	if get_tree().current_scene.name != "main": return
	var main:Main = get_tree().current_scene
	var player:Player = main.get_node(str(get_tree().get_network_unique_id()))
	if player.coins >= price:
		player.coins -= price
		main.get_node("gameInterface/TabContainer/Shop/coinCounter/Label").text = str(player.coins)
		if modifiers.rubyChance > 0:
			if !main.coinChance.keys().has("ruby"):
				main.coinChance.ruby = modifiers.rubyChance
			else:
				main.coinChance.ruby += modifiers.rubyChance

		queue_free()
