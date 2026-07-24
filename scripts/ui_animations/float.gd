extends Control
class_name AnimationFloat

@export var duration : float = 4.0
@export var distance : float = 10.0

var _target : Control

func _ready() -> void:
    _target = get_parent()
    _target.offset_transform_enabled = true

    mouse_filter = Control.MOUSE_FILTER_PASS

    _animate()


func _animate():
    var tween = create_tween()

    tween.set_loops()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_IN_OUT)

    tween.tween_property(_target, "offset_transform_position", Vector2(0, distance), duration)
    tween.tween_property(_target, "offset_transform_position", Vector2.ZERO, duration)
    