extends Control

@onready var accept_button: Button = $ColorRect/AcceptButton
@onready var deny_button: Button = $ColorRect/DenyButton
@onready var label: Label = $ColorRect/Label

var index_to_remove: int = 0

func _ready() -> void:
	pass

func _on_accept_button_button_up() -> void:
	return

func _on_deny_button_button_up() -> void:
	return
