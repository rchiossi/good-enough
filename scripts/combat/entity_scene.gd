extends MarginContainer
class_name EntityScene

@onready var _health_bar : ProgressBar = %HealthBar
@onready var _armor_bar : ProgressBar = %ArmorBar
@onready var _shield_bar : ProgressBar = %ShieldBar

@onready var _sprite : TextureRect = %Sprite

const animation_attack_duration : float = 0.3
const animation_damage_duration : float = 0.3

var _tween : Tween

func init(health : int, armor : int, shield : int, sprite : Texture2D):
	offset_transform_enabled = true

	_health_bar.max_value = health
	_health_bar.value = health

	_armor_bar.max_value = armor
	_armor_bar.value = armor

	_shield_bar.max_value = shield
	_shield_bar.value = shield

	_sprite.texture = sprite

func animate_attack():
	if _tween and _tween.is_running():
		return

	_tween = create_tween()

	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "offset_transform_position", offset_transform_position + Vector2(100, 0), animation_attack_duration)
	_tween.chain().tween_property(self, "offset_transform_position", offset_transform_position, animation_attack_duration)

func animate_take_damage():
	if _tween and _tween.is_running():
		return
	_tween = create_tween()

	_tween.set_trans(Tween.TRANS_BOUNCE)
	_tween.set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "offset_transform_scale", Vector2.ONE * 0.8, animation_attack_duration)
	_tween.chain().tween_property(self, "offset_transform_scale", Vector2.ONE, animation_attack_duration)
