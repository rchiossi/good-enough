extends Control
class_name HoverSound

#@export var pressed_sound: AudioStream = load("res://resources/effects/button_press.ogg")
@export var hover_sound: AudioStream = preload("uid://dgnmyji1yijho")

var player: AudioStreamPlayer2D

var _target : Control

func _ready() -> void:
    _target = get_parent()
    player = AudioStreamPlayer2D.new()
    add_child(player)
    player.stream = hover_sound

    mouse_filter = Control.MOUSE_FILTER_PASS
    #_target.pressed.connect(on_button_pressed)
    _target.mouse_entered.connect(on_hover)

#func on_button_pressed()->void:
    #SoundManager.play_ui_sound(pressed_sound)

func on_hover():
    player.play()
