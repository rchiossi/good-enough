extends Control
class_name AnimationScaleTwitch

@export var duration : float = 0.3

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
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(_target, "offset_transform_scale", Vector2.ONE * 1.1, duration)
	tween.parallel().tween_property(_target, "offset_transform_rotation", deg_to_rad(2.0 * [-1.0, 1.0].pick_random()), duration)

func _animate_out():
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(_target, "offset_transform_scale", Vector2.ONE, duration)
	tween.parallel().tween_property(_target, "offset_transform_rotation", 0.0, duration)




