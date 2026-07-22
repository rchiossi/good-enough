extends MarginContainer
class_name SettingsPanel

@onready var master_slider : HSlider = %MasterSlider
@onready var music_slider : HSlider = %MusicSlider
@onready var sfx_slider : HSlider = %SfxSlider

@onready var close_button : Button = %CloseButton

var _master_idx : int
var _music_idx : int
var _sfx_idx : int

@export var fade_duration : float = 0.3

var _last_focus : Control

func _ready() -> void:
    _master_idx = AudioServer.get_bus_index("Master")
    _music_idx = AudioServer.get_bus_index("Music")
    _sfx_idx = AudioServer.get_bus_index("Sfx")

    master_slider.value = AudioServer.get_bus_volume_linear(_master_idx)
    music_slider.value = AudioServer.get_bus_volume_linear(_music_idx)
    sfx_slider.value = AudioServer.get_bus_volume_linear(_sfx_idx)

    master_slider.value_changed.connect(_on_master_value_changed)
    music_slider.value_changed.connect(_on_music_value_changed)
    sfx_slider.value_changed.connect(_on_sfx_value_changed)

    close_button.pressed.connect(_on_close_button_pressed)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        fade_out()

func _on_close_button_pressed():
    fade_out()

func _on_master_value_changed():
    AudioServer.set_bus_volume_linear(_master_idx, master_slider.value)

func _on_music_value_changed():
    AudioServer.set_bus_volume_linear(_music_idx, music_slider.value)

func _on_sfx_value_changed():
    AudioServer.set_bus_volume_linear(_sfx_idx, sfx_slider.value)

func fade_in() -> void:
    modulate.a = 0.0
    show()

    var tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(self, "modulate:a", 1.0, fade_duration)

    _last_focus = get_viewport().gui_get_focus_owner()
    master_slider.grab_focus.call_deferred()

    set_process_input(true)

func fade_out() -> void:
    var tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(self, "modulate:a", 0.0, fade_duration)
    tween.tween_callback(hide)

    if _last_focus:
        _last_focus.grab_focus()
    
    set_process_input(false)
