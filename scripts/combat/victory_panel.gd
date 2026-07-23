extends MarginContainer

@onready var _continue_button : Button = %ContinueButton

func _ready() -> void:
    _continue_button.pressed.connect(_on_continue)

func _on_continue() -> void:
    SceneLoader.load_scene("uid://clhtpadgac6l7")