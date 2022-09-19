extends Control
var deck := preload("res://cardDeck.tscn")

func _ready():
	var cards = deck.instance().get_children()
	for i in range(0,3):
		var randomCard:Card = cards[randi() % len(cards)]
		while $HBoxContainer.get_children().has(randomCard):
			randomCard = cards[randi() % len(cards)]
		randomCard.get_parent().remove_child(randomCard)
		$HBoxContainer.add_child(randomCard)
