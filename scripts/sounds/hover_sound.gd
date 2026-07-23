extends Control
class_name HoverSound

@export var hover_sound: AudioStream = preload("uid://dgnmyji1yijho")
@export var bus: StringName = "Sfx"

var player: AudioStreamPlayer2D

var _target : Control

func _ready() -> void:
    _target = get_parent()
    player = AudioStreamPlayer2D.new()
    player.bus = bus
    add_child(player)
    player.stream = hover_sound

    mouse_filter = Control.MOUSE_FILTER_PASS
    _target.mouse_entered.connect(on_hover)

func on_hover():
    player.play()
