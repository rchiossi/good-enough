extends Control

@onready var start_button : Button = %StartButton
@onready var settings_button : Button = %SettingsButton
@onready var exit_button : Button = %ExitButton

@onready var _exit_dialog : SimpleDialog = %ExitDialog
@onready var _settings_panel : SettingsPanel = %SettingsPanel

func _ready() -> void:
	exit_button.pressed.connect(_on_exit_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)

	_exit_dialog.confirmed.connect(_on_exit)

	start_button.grab_focus.call_deferred()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_exit_dialog.fade_in()

func _on_exit_button_pressed() -> void:
	_exit_dialog.fade_in()

func _on_exit() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	SceneLoader.load_scene("res://scenes/dummy_scene.tscn")

func _on_settings_button_pressed() -> void:
	_settings_panel.fade_in()
