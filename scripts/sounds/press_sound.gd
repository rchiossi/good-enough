extends Control
class_name PressSound

@export var press_sound: AudioStream = preload("uid://drooitmjvka4i")
@export var bus: StringName = "Sfx"

var player: AudioStreamPlayer2D

var _target : Control

func _ready() -> void:
    _target = get_parent()
    player = AudioStreamPlayer2D.new()
    player.bus = bus
    add_child(player)
    player.stream = press_sound

    mouse_filter = Control.MOUSE_FILTER_PASS
    _target.pressed.connect(on_button_pressed)

func on_button_pressed()->void:
    player.play()
