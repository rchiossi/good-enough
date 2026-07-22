extends Control

@onready var abilities_list: HBoxContainer = $AbilitiesList

func _ready() -> void:
	for ability in GameState.player_abilities:
		var button := Button.new()
		button.icon = load(ability.IconPath)
		button.text = "Fireball"
		button.pressed.connect(_on_button_pressed)
		abilities_list.add_child(button)

func _on_button_pressed() -> void:
	pass
