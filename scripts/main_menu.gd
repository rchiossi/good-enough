extends Control

@onready var start_button : Button = %StartButton
@onready var settings_button : Button = %SettingsButton
@onready var exit_button : Button = %ExitButton

@onready var _exit_dialog : SimpleDialog = %ExitDialog
@onready var _settings_panel : SettingsPanel = %SettingsPanel

@onready var _credits_panel : MarginContainer = %CreditsPanel
@onready var _credits_button : Button = %CreditsButton
@onready var _credits_close_button : Button = %CreditsCloseButton

func _ready() -> void:
    exit_button.pressed.connect(_on_exit_button_pressed)
    settings_button.pressed.connect(_on_settings_button_pressed)
    start_button.pressed.connect(_on_start_button_pressed)

    _exit_dialog.confirmed.connect(_on_exit)

    _credits_button.pressed.connect(_on_credits_open)
    _credits_close_button.pressed.connect(_on_credits_close)

    start_button.grab_focus.call_deferred()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        _exit_dialog.fade_in()

func _on_exit_button_pressed() -> void:
    _exit_dialog.fade_in()

func _on_exit() -> void:
    get_tree().quit()

func _on_start_button_pressed() -> void:
    for autoload in get_tree().root.get_children():
        print("autoload", autoload)
        if autoload.has_method("reset"):
            autoload.call("reset")
    SceneLoader.load_scene("res://scenes/events/tutorial.tscn")

func _on_settings_button_pressed() -> void:
    _settings_panel.fade_in()

func _on_credits_open() -> void:
    _credits_panel.show()

func _on_credits_close() -> void:
    _credits_panel.hide()
