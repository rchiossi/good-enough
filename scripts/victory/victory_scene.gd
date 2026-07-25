extends MarginContainer

@onready var _player : TextureRect = %Player

@onready var _m1 : RichTextLabel = %M1
@onready var _m2 : RichTextLabel = %M2
@onready var _m3 : RichTextLabel = %M3
@onready var _m4 : RichTextLabel = %M4
@onready var _m5 : RichTextLabel = %M5
@onready var _m6 : RichTextLabel = %M6
@onready var _m7 : RichTextLabel = %M7
@onready var _m8 : RichTextLabel = %M8

@onready var _main_menu_button : Button = %MainMenuButton

@onready var _title : TextureRect = %Title

@export var step_duration : float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _main_menu_button.pressed.connect(_on_main_menu)

    _player.modulate.a = 0.0

    _m1.modulate.a = 0.0
    _m2.modulate.a = 0.0
    _m3.modulate.a = 0.0
    _m4.modulate.a = 0.0
    _m5.modulate.a = 0.0
    _m6.modulate.a = 0.0
    _m7.modulate.a = 0.0
    _m8.modulate.a = 0.0

    _main_menu_button.modulate.a = 0.0
    _main_menu_button.disabled = true

    _title.modulate.a = 0.0

    play.call_deferred()

func play():
    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_interval(step_duration)
    tween.tween_property(_player, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m1, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m2, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m3, "modulate:a", 1.0, step_duration*2)
    tween.tween_property(_m4, "modulate:a", 1.0, step_duration*2)
    tween.tween_property(_m5, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m6, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m7, "modulate:a", 1.0, step_duration)
    tween.parallel().tween_property(_m8, "modulate:a", 1.0, step_duration)
    tween.parallel().tween_property(_main_menu_button, "modulate:a", 1.0, step_duration)
    tween.parallel().tween_property(_title, "modulate:a", 1.0, step_duration)
    tween.tween_callback(func(): _main_menu_button.disabled = false)

func _on_main_menu():
    SceneLoader.load_scene("uid://dtorqehcnwdl6")
