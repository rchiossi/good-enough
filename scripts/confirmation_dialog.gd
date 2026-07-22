extends Control
class_name SimpleDialog

@onready var confirm_button : Button = %ConfirmButton
@onready var cancel_button : Button = %CancelButton
@onready var dialog_text_label : Label = %DialogTextLabel

signal confirmed
signal canceled

@export var dialog_text : String = "Simple Dialog" :
    set(value): 
        dialog_text = value
        if is_node_ready():
            dialog_text_label.text = value

@export var confirm_text : String = "Confirm" :
    set(value): 
        confirm_text = value
        if is_node_ready():
            confirm_button.text = value

@export var cancel_text : String = "Cancel" :
    set(value): 
        cancel_text = value
        if is_node_ready():
            cancel_button.text = value

@export var fade_duration : float = 0.3

var _last_focus : Control

func _ready() -> void:
    set_process_input(false)

    confirm_button.pressed.connect(_on_confirmed)
    cancel_button.pressed.connect(_on_canceled)

    _set_text.call_deferred()

    hide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_viewport().set_input_as_handled()
        _on_canceled()

func _set_text():
    dialog_text_label.text = dialog_text
    cancel_button.text = cancel_text
    confirm_button.text = confirm_text

func _on_confirmed() -> void:
    confirmed.emit()
    fade_out()

func _on_canceled() -> void:
    canceled.emit()
    fade_out()

func fade_in() -> void:
    modulate.a = 0.0
    show()

    var tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(self, "modulate:a", 1.0, fade_duration)

    _last_focus = get_viewport().gui_get_focus_owner()
    cancel_button.grab_focus.call_deferred()

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
