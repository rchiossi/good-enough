extends Control
class_name BgMusic

@export var hover_sound: AudioStream = preload("uid://di53iumxc34jq")
@export var bus: StringName = "Music"
@export var start_time: float = 0.0

var player: AudioStreamPlayer2D

func _ready() -> void:
    player = AudioStreamPlayer2D.new()
    player.bus = bus
    add_child(player)
    player.stream = hover_sound

    mouse_filter = Control.MOUSE_FILTER_PASS

    player.play(start_time)
