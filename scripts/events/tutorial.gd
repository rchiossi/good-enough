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
@onready var _m9 : RichTextLabel = %M9
@onready var _m10 : RichTextLabel = %M10
@onready var shield_info : HBoxContainer = %ShieldInfo
@onready var armor_info : HBoxContainer = %ArmorInfo
@onready var health_info : HBoxContainer = %HealthInfo

@onready var _m14 : RichTextLabel = %M14
@onready var event_info : HBoxContainer = %EventInfo
@onready var fight_info : HBoxContainer = %FightInfo
@onready var _m15 : RichTextLabel = %M15

@onready var _main_menu_button : Button = %Continue

@onready var _title : TextureRect = %Title

@export var step_duration : float = 2.0

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _player.modulate.a = 0.0

    _m1.modulate.a = 0.0
    _m2.modulate.a = 0.0
    _m3.modulate.a = 0.0
    _m4.modulate.a = 0.0
    _m5.modulate.a = 0.0
    _m6.modulate.a = 0.0
    _m7.modulate.a = 0.0
    _m8.modulate.a = 0.0
    _m9.modulate.a = 0.0
    _m10.modulate.a = 0.0
    _m14.modulate.a = 0.0
    _m15.modulate.a = 0.0
    shield_info.modulate.a = 0.0
    armor_info.modulate.a = 0.0
    health_info.modulate.a = 0.0
    event_info.modulate.a = 0.0
    fight_info.modulate.a = 0.0

    _main_menu_button.modulate.a = 0.0
    _main_menu_button.disabled = true

    _title.modulate.a = 0.0

    play.call_deferred()

func play():
    tween = create_tween()

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
    tween.tween_interval(2.0)
    tween.tween_property(_m7, "modulate:a", 1.0, step_duration)
    tween.tween_interval(1.0)
    tween.tween_property(_m14, "modulate:a", 1.0, step_duration)
    tween.tween_property(event_info, "modulate:a", 1.0, step_duration)
    tween.tween_property(fight_info, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m15, "modulate:a", 1.0, step_duration)
    tween.tween_interval(1.0)
    tween.tween_property(_m8, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m9, "modulate:a", 1.0, step_duration)
    tween.tween_property(_m10, "modulate:a", 1.0, step_duration)
    tween.tween_property(shield_info, "modulate:a", 1.0, step_duration)
    tween.tween_property(armor_info, "modulate:a", 1.0, step_duration)
    tween.tween_property(health_info, "modulate:a", 1.0, step_duration)
    tween.parallel().tween_property(_main_menu_button, "modulate:a", 1.0, step_duration)
    tween.parallel().tween_property(_title, "modulate:a", 1.0, step_duration)
    tween.tween_callback(func(): 
        _main_menu_button.disabled = false
        %Skip.visible = false
        %SkipAll.visible = false
    )

func _on_continue_pressed() -> void:
    SceneLoader.load_scene("uid://bqa756pyqync2")

func _on_skip_pressed() -> void:
    if tween and tween.is_valid():
        tween.custom_step(step_duration)


func _on_skip_all_pressed() -> void:
    if tween and tween.is_valid():
        step_duration = 0
        tween.custom_step(200)
