extends Node
class_name CombatBgMusic

@export var normal_battle: AudioStream = preload("uid://dus1aaf71ert7")
@export var boss_phase_1: AudioStream = preload("uid://bsauv1t8m0xah")
@export var boss_phase_2: AudioStream = preload("uid://byymbelyuxg1a")
@export var bus: StringName = "Music"
@export var start_time: float = 1.0

var player: AudioStreamPlayer2D

func _ready() -> void:
    player = AudioStreamPlayer2D.new()
    player.bus = bus
    add_child(player)

func _play_normal():
    player.stream = normal_battle
    player.play(start_time)

func _play_boss_phase_1():
    player.stream = boss_phase_1
    player.play(start_time)

func _play_boss_phase_2():
    player.stream = boss_phase_2
    player.play(start_time)