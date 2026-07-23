extends Control

@onready var accept_button: Button = $ColorRect/AcceptButton
@onready var deny_button: Button = $ColorRect/DenyButton
@onready var label: Label = $ColorRect/Label

var index_to_remove: int = 0

func _ready() -> void:
	index_to_remove = randi_range(0, len(GameState.player_abilities.values()))
	var ability_1 = GameState.player_abilities.values()[index_to_remove].Name
	label.text = "Existential Mushroom

You eat a strange mushroom.
Moments later you're wondering whether your 
enemies are merely projections of your own
subconscious.

You gain +5 health but can't ever cast " + ability_1 + "."

func _on_accept_button_button_up() -> void:
	print("Enlightment accepted, you gain +5 health")
	GameState.player_stats.health += 5
	print("len=" + str(len(GameState.player_abilities)))
	GameState.player_abilities.erase(GameState.player_abilities.keys()[index_to_remove])
	SceneLoader.load_scene("res://scenes/abilities_window.tscn")

func _on_deny_button_button_up() -> void:
	print("Enlightment purged")
	SceneLoader.load_scene("res://scenes/abilities_window.tscn")
