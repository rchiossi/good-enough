extends MarginContainer
class_name EntityScene

@onready var _health_bar : ProgressBar = %HealthBar
@onready var _armor_bar : ProgressBar = %ArmorBar
@onready var _shield_bar : ProgressBar = %ShieldBar

@onready var _sprite : TextureRect = %Sprite

const animation_attack_duration : float = 0.3
const animation_damage_duration : float = 0.3

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
	print("attack")
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "offset_transform_position", offset_transform_position + Vector2(100, 0), animation_attack_duration)
	tween.chain().tween_property(self, "offset_transform_position", offset_transform_position, animation_attack_duration)

func animate_take_damage():
	print("attack")
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "offset_transform_scale", Vector2.ONE * 0.8, animation_attack_duration)
	tween.chain().tween_property(self, "offset_transform_scale", Vector2.ONE, animation_attack_duration)