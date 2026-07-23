extends Control
class_name AnimationScaleBounce

@export var duration : float = 0.3
@export var scale_percentage : float = 1.5

var _target : TextureButton

func _ready() -> void:
    _target = get_parent()
    _target.offset_transform_enabled = true

    mouse_filter = Control.MOUSE_FILTER_PASS

    _target.button_down.connect(_animate_in)
    _target.button_up.connect(_animate_out)

func _animate_in():
    _target.z_index += 1

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_target, "offset_transform_scale", Vector2.ONE * scale_percentage, duration)
    
func _animate_out():
    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_target, "offset_transform_scale", Vector2.ONE, duration)
    tween.tween_callback(func (): _target.z_index -= 1)
