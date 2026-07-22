extends MarginContainer
class_name EntityScene

@onready var _health_bar : ProgressBar = %HealthBar
@onready var _armor_bar : ProgressBar = %ArmorBar
@onready var _shield_bar : ProgressBar = %ShieldBar

@onready var _sprite : TextureRect = %Sprite

func init(health : int, armor : int, shield : int, sprite : Texture2D):
	_health_bar.max_value = health
	_health_bar.value = health

	_armor_bar.max_value = armor
	_armor_bar.value = armor

	_shield_bar.max_value = shield
	_shield_bar.value = shield

	_sprite.texture = sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
