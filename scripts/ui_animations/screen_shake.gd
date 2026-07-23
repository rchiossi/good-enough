extends Control
class_name AnimationScreenShake

@export var duration : float = 0.3
@export var strenght : float = 2.0

var _target : Control

var _tween :  Tween

func _ready() -> void:
    _target = get_parent()
    _target.offset_transform_enabled = true

    mouse_filter = Control.MOUSE_FILTER_PASS

func shake():
    if _tween:
        _tween.kill()

    _tween = create_tween()

    _tween.tween_method(shake_method, 1.0, 0.0, duration)
    _tween.tween_property(_target, "offset_transform_position", Vector2.ZERO, 0.1)

func shake_method(delay: float):     
    var movement = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strenght * delay
    _target.offset_transform_position += movement
