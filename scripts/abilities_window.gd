extends Control

@onready var abilities_list: HBoxContainer = $AbilitiesList
const ICON_SIZE := 128

func _ready() -> void:
    for ability in GameState.player_abilities.values():
        var button := Button.new()
        button.icon = ability.Icon
        button.expand_icon = true
        button.add_theme_constant_override("icon_max_width", ICON_SIZE)
        button.pressed.connect(_on_button_pressed)
        button.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
        abilities_list.add_child(button)

func _on_button_pressed() -> void:
    pass
