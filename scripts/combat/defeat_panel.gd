extends MarginContainer

@onready var main_menu_button : Button = %MainMenuButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_main_menu_button_pressed() -> void:
    SceneLoader.load_scene("uid://dtorqehcnwdl6")
