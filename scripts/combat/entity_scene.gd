extends MarginContainer
class_name EntityScene

@onready var _health_bar : StatusBar = %HealthBar
@onready var _armor_bar : StatusBar = %ArmorBar
@onready var _shield_bar : StatusBar = %ShieldBar

@onready var _sprite : TextureRect = %Sprite

@onready var _stats_panel : VBoxContainer = %StatsPanel

const animation_attack_duration : float = 0.3
const animation_damage_duration : float = 1.5

var _tween : Tween

@export var death_animation_duration : float = 0.5

signal death_animation_complete
signal possible_damage(hp: int, armour: int, shield: int)

var stats : EntityStats

func init(entity_stats: EntityStats):
    offset_transform_enabled = true

    stats = entity_stats

    _health_bar.init(stats.health, stats.max_health)
    _armor_bar.init(stats.armor, stats.max_armor)
    _shield_bar.init(stats.shield, stats.max_shield)

    stats.hp_changed.connect(_health_bar.animate_change.bind(animation_damage_duration))
    stats.armor_changed.connect(_armor_bar.animate_change.bind(animation_damage_duration))
    stats.shield_changed.connect(_shield_bar.animate_change.bind(animation_damage_duration))

    if stats.shield == 0:
        _shield_bar.hide()

    if stats.armor == 0:
        _armor_bar.hide()

    _sprite.texture = entity_stats.sprite
    
    possible_damage.connect(_show_damage_indication)

    animate_idle()

func _show_damage_indication(hp_damage: int, armor_damage: int, shield_damage: int):
    if shield_damage != 0:
        _shield_bar.indicate_damage(shield_damage)

    var remaining_shield = max(stats.shield - shield_damage, 0)
    if remaining_shield != 0:
        return

    if armor_damage != 0:
        _armor_bar.indicate_damage(armor_damage)
    
    var remaining_armor = max(stats.armor - armor_damage, 0)
    if remaining_armor != 0:
        return

    if hp_damage != 0:
        _health_bar.indicate_damage(hp_damage)

func clear_damage_indication():
    _health_bar.clear_damage_indication()
    _armor_bar.clear_damage_indication()
    _shield_bar.clear_damage_indication()

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

func animate_death():
    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_sprite, "material:shader_parameter/flash_color", Color("#b34947"), death_animation_duration)
    tween.parallel().tween_property(_sprite, "material:shader_parameter/flash_percentage", 1.0, death_animation_duration)
    tween.parallel().tween_property(_stats_panel, "modulate:a", 0.0, death_animation_duration)

    tween.tween_callback(func(): death_animation_complete.emit())
