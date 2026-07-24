extends Control
class_name AnimationScaleTwitch

@export_category("Animation")
@export var duration : float = 0.3

@export_category("Scale Animation")
@export var enable_scale : bool = true
@export var scale_amount : float = 1.1

@export_category("Twitch Animation")
@export var enable_twitch : bool = false
@export var twitch_strength : float = 2.0

var _target : Control

func _ready() -> void:
    _target = get_parent()
    _target.offset_transform_enabled = true

    mouse_filter = Control.MOUSE_FILTER_PASS

    _target.mouse_entered.connect(_animate_in)
    _target.mouse_exited.connect(_animate_out)

    _target.focus_entered.connect(_animate_in)
    _target.focus_exited.connect(_animate_out)

func _animate_in():
    if not enable_scale and not enable_twitch:
        return

    _target.z_index += 1

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    if enable_scale:
        tween.tween_property(_target, "offset_transform_scale", Vector2.ONE * scale_amount, duration)
    if enable_twitch:
        tween.parallel().tween_property(_target, "offset_transform_rotation", deg_to_rad(twitch_strength * [-1.0, 1.0].pick_random()), duration)

func _animate_out():
    if not enable_scale and not enable_twitch:
        return

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    if enable_scale:
        tween.tween_property(_target, "offset_transform_scale", Vector2.ONE, duration)
    if enable_twitch:
        tween.parallel().tween_property(_target, "offset_transform_rotation", 0.0, duration)

    _target.z_index -= 1
