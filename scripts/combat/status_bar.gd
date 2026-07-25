extends MarginContainer
class_name StatusBar

@onready var _main_bar : ProgressBar = %MainBar
@onready var _damage_bar : ProgressBar = %DamageBar

@onready var _current_label : Label = %CurrentLabel
@onready var _max_label : Label = %MaxLabel

@export var lead_percentage= 0.5
@export var pause_percentage = 0.25
@export var tail_percentage = 0.25

@export var main_color : Color = Color("#6b304b")
@export var damage_color : Color = Color("#8d8381")

func init(current_value: int, max_value: int) -> void:
    _main_bar.max_value = max_value
    _main_bar.value = current_value
    
    _damage_bar.max_value = max_value
    _damage_bar.value = current_value

    _max_label.text = str(max_value)

    _current_label.text = str(current_value)

    var main_style_box : StyleBoxFlat = _main_bar.get_theme_stylebox("fill").duplicate()
    main_style_box.bg_color = damage_color # the main bar is bellow
    _main_bar.add_theme_stylebox_override("fill", main_style_box)

    var damage_style_box : StyleBoxFlat = _damage_bar.get_theme_stylebox("fill").duplicate()
    damage_style_box.bg_color = main_color # the damage bar is above
    _damage_bar.add_theme_stylebox_override("fill", damage_style_box)

func indicate_damage(damage: int):
    _damage_bar.value = max(_damage_bar.value - damage, 0)

func clear_damage_indication():
    _damage_bar.value = _main_bar.value

func animate_change(old_value: int, new_value: int, duration: float, immediate: bool = false):
    clear_damage_indication()

    var tween = create_tween()

    #tween.set_trans(Tween.TRANS_SINE)
    #tween.set_ease(Tween.EASE_OUT)

    if immediate:
        tween.tween_property(_damage_bar, "value", new_value, duration)
        tween.parallel().tween_property(_main_bar, "value", new_value, duration)
        tween.parallel().tween_method(func (value): _current_label.text = str(value), old_value, new_value, duration)
    else:
        tween.tween_property(_damage_bar, "value", new_value, duration * lead_percentage)
        tween.tween_interval(duration * pause_percentage)
        tween.tween_property(_main_bar, "value", new_value, duration * tail_percentage)
        tween.parallel().tween_method(func (value): _current_label.text = str(value), old_value, new_value, duration)
