extends Control
var deck := preload("res://gameMenu/cardDeck.tscn")

var maxCards := 3


func _ready():
	for child in $HBoxContainer.get_children():
		child.queue_free()
	yield(get_tree(), "idle_frame")
	refill()


func refill():
	var cards = deck.instance().get_children()
	for i in range(0, maxCards - len($HBoxContainer.get_children())):
		var randomCard: Card = cards[randi() % len(cards)]
		while $HBoxContainer.get_children().has(randomCard):
			randomCard = cards[randi() % len(cards)]
		randomCard.get_parent().remove_child(randomCard)
		$HBoxContainer.add_child(randomCard)


func _on_refresh_pressed():
	if Global.player.coins > 0:
		_ready()
