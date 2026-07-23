extends MarginContainer
class_name EntityScene

@onready var _health_bar : ProgressBar = %HealthBar
@onready var _armor_bar : ProgressBar = %ArmorBar
@onready var _shield_bar : ProgressBar = %ShieldBar

@onready var _current_hp_label : Label = %CurrentHpLabel
@onready var _max_hp_label : Label = %MaxHpLabel
@onready var _current_armor_label : Label = %CurrentArmorLabel
@onready var _max_armor_label : Label = %MaxArmorLabel
@onready var _current_shield_label : Label = %CurrentShieldLabel
@onready var _max_shield_label : Label = %MaxShieldLabel

@onready var _sprite : TextureRect = %Sprite

const animation_attack_duration : float = 0.3
const animation_damage_duration : float = 0.3

var _tween : Tween

@export var bar_animation_duration : float = 2.0
@export var death_animation_duration : float = 2.0

signal death_animation_complete

func init(health : int, armor : int, shield : int, sprite : Texture2D):
    offset_transform_enabled = true

    _health_bar.max_value = health
    _health_bar.value = health
    _current_hp_label.text = str(health)
    _max_hp_label.text = str(health)

    _armor_bar.max_value = armor
    _armor_bar.value = armor
    _current_armor_label.text = str(armor)
    _max_armor_label.text = str(armor)

    _shield_bar.max_value = shield
    _shield_bar.value = shield
    _current_shield_label.text = str(shield)
    _max_shield_label.text = str(shield)

    _sprite.texture = sprite

    animate_idle()

func animate_idle():
    var tween = create_tween()

    tween.set_loops()

    tween.tween_interval(randf() * 3.0)
    tween.tween_property(_sprite, "offset_transform_position", Vector2(10, -5), 0.5)
    tween.tween_property(_sprite, "offset_transform_position", Vector2(20, 0), 0.5)
    tween.tween_interval(randf() * 3.0)
    tween.tween_property(_sprite, "offset_transform_position", Vector2(10, -5), 0.5)
    tween.tween_property(_sprite, "offset_transform_position", Vector2(0, 0), 0.5)

func animate_attack():
    if _tween and _tween.is_running():
        return

    _tween = create_tween()

    _tween.set_trans(Tween.TRANS_SINE)
    _tween.set_ease(Tween.EASE_OUT)

    _tween.tween_property(_sprite, "offset_transform_position", offset_transform_position + Vector2(100, 0), animation_attack_duration)
    _tween.chain().tween_property(_sprite, "offset_transform_position", offset_transform_position, animation_attack_duration)

func animate_take_damage():
    if _tween and _tween.is_running():
        return
    _tween = create_tween()

    _tween.set_trans(Tween.TRANS_BOUNCE)
    _tween.set_ease(Tween.EASE_OUT)

    _tween.tween_property(_sprite, "material:shader_parameter/flash_percentage", 1.0, 0.1)
    _tween.tween_property(_sprite, "material:shader_parameter/flash_percentage", 0.0, 0.1)
    _tween.tween_property(_sprite, "material:shader_parameter/flash_percentage", 1.0, 0.1)
    _tween.tween_property(_sprite, "material:shader_parameter/flash_percentage", 0.0, 0.1)

func _animate_bar(bar: ProgressBar, label: Label, old_value: int, new_value : int):
    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(bar, "value", new_value, bar_animation_duration)
    tween.parallel().tween_method(_tween_label.bind(label), old_value, new_value, bar_animation_duration)

func _tween_label(new_value: int, label: Label):
    label.text = str(new_value)

func animate_health_bar(old_value: int, new_value: int):
    _animate_bar(_health_bar, _current_hp_label, old_value, new_value)

func animate_armor_bar(old_value: int, new_value: int):
    _animate_bar(_armor_bar, _current_armor_label, old_value, new_value)

func animate_shield_bar(old_value: int, new_value: int):
    _animate_bar(_shield_bar, _current_shield_label, old_value, new_value)

func animate_death():
    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_sprite, "material:shader_parameter/flash_color", Color.RED, death_animation_duration)
    tween.parallel().tween_property(_sprite, "material:shader_parameter/flash_percentage", 1.0, death_animation_duration)
    tween.parallel().tween_property(self, "modulate:a", 0.0, death_animation_duration)

    tween.tween_callback(func(): death_animation_complete.emit())
