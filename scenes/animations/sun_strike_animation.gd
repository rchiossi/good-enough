extends Node2D

class_name SunStrikeAnimation

@onready var demon_bite_animation: AnimatedSprite2D = $DemonBiteAnimation
@onready var lightning_bolt_animation: AnimatedSprite2D = $LightningBoltAnimation
@onready var celestial_bonk_animation: AnimatedSprite2D = $CelestialBonkAnimation
@onready var lightning_bolt_sound: AudioStreamPlayer2D = $LightningBoltSound
@onready var celestial_bonk_sound: AudioStreamPlayer2D = $CelestialBonkSound

@onready var fire_tornado_animation: AnimatedSprite2D = $IncinerateAnimation
@onready var fire_tornado_sound: AudioStreamPlayer2D = $IncinerateSound

@onready var water_blast_animation: AnimatedSprite2D = $WaterBlastAnimation
@onready var water_blast_sound: AudioStreamPlayer2D = $WaterBlastSound

@onready var water_surge_animation: AnimatedSprite2D = $WaterSurgeAnimation
@onready var water_surge_sound: AudioStreamPlayer2D = $WaterSurgeSound

@onready var phoenix_flame_animation: AnimatedSprite2D = $PhoenixFlameAnimation
@onready var phoenix_flame_sound: AudioStreamPlayer2D = $PhoenixFlameSound

@onready var blood_bend_big_animation: AnimatedSprite2D = $BloodBendBigAnimation
@onready var blood_bend_big_sound: AudioStreamPlayer2D = $BloodBendBigSound

@onready var blood_bend_medium_sound: AudioStreamPlayer2D = $BloodBendMediumSound
@onready var blood_bend_medium_animation: AnimatedSprite2D = $BloodBendMediumAnimation

@onready var dark_spike_animation: AnimatedSprite2D = $DarkSpikeAnimation
@onready var dark_spike_sound: AudioStreamPlayer2D = $DarkSpikeSound

@onready var ice_tomb_animation: AnimatedSprite2D = $IceTombAnimation
@onready var ice_tomb_sound: AudioStreamPlayer2D = $IceTombSound

@onready var abyssal_pain_sound: AudioStreamPlayer2D = $AbyssalPainSound
@onready var abyssal_pain_animation: AnimatedSprite2D = $AbyssalPainAnimation

@onready var tornado_animation: AnimatedSprite2D = $TornadoAnimation
@onready var tornado_sound: AudioStreamPlayer2D = $TornadoSound

@onready var heal_animation: AnimatedSprite2D = $HealAnimation
@onready var heal_sound: AudioStreamPlayer2D = $HealSound

@onready var armor_heal_animation: AnimatedSprite2D = $ArmorHealAnimation
@onready var armor_heal_sound: AudioStreamPlayer2D = $ArmorHealSound

@onready var electric_torpedo_animation: AnimatedSprite2D = $ElectricTorpedoAnimation
@onready var electric_torpedo_sound: AudioStreamPlayer2D = $ElectricTorpedoSound

@onready var ice_dart_sound: AudioStreamPlayer2D = $IceDartSound
@onready var ice_dart_animation: AnimatedSprite2D = $IceDartAnimation

signal animation_completed

var _active_animation: AnimatedSprite2D = null
var _is_sound_done = false
var _is_animation_done = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

func play(animation_type: Ability.AnimationType, position_to_paint : Vector2, size: Vector2):
    assert(animation_type != Ability.AnimationType.NONE)

    var sound : AudioStreamPlayer2D = null

    print("ANIMATION_TYPE=", animation_type)
    if animation_type == Ability.AnimationType.DARK_SPIKE_EXPLOSION:
        _active_animation = dark_spike_animation
        sound = dark_spike_sound
    if animation_type == Ability.AnimationType.LIGHTNING_BOLT:
        sound = lightning_bolt_sound
        _active_animation = lightning_bolt_animation
    if animation_type == Ability.AnimationType.CELESTIAL_BONK:
        sound = celestial_bonk_sound
        _active_animation = celestial_bonk_animation
    if animation_type == Ability.AnimationType.FIRE_TORNADO:
        sound = fire_tornado_sound
        _active_animation = fire_tornado_animation
    if animation_type == Ability.AnimationType.WATER_BLAST:
        sound = water_blast_sound
        _active_animation = water_blast_animation
    if animation_type == Ability.AnimationType.WATER_SURGE:
        sound = water_surge_sound
        _active_animation = water_surge_animation
    if animation_type == Ability.AnimationType.PHOENIX_FLAME:
        sound = phoenix_flame_sound
        _active_animation = phoenix_flame_animation
    if animation_type == Ability.AnimationType.BLOOD_BEND_BIG:
        _active_animation = blood_bend_big_animation
        sound = blood_bend_big_sound
    if animation_type == Ability.AnimationType.BLOOD_BEND_MEDIUM:
        _active_animation = blood_bend_medium_animation
        sound = blood_bend_medium_sound
    if animation_type == Ability.AnimationType.FROST_TOMB:
        _active_animation = ice_tomb_animation
        sound = ice_tomb_sound
    if animation_type == Ability.AnimationType.TORNADO:
        _active_animation = tornado_animation
        sound = tornado_sound
    if animation_type == Ability.AnimationType.ABYSSAL_SURGE:
        _active_animation = abyssal_pain_animation
        sound = abyssal_pain_sound
    if animation_type == Ability.AnimationType.HEAL:
        _active_animation = heal_animation
        sound = heal_sound
    if animation_type == Ability.AnimationType.HEAL_ARMOR:
        _active_animation = armor_heal_animation
        sound = armor_heal_sound
    if animation_type == Ability.AnimationType.ELECTRIC_TORPEDO:
        _active_animation = electric_torpedo_animation
        sound = electric_torpedo_sound
    if animation_type == Ability.AnimationType.ICE_DART:
        _active_animation = ice_dart_animation
        sound = ice_dart_sound

    _active_animation.animation_finished.connect(_on_animation_completed)

    _active_animation.visible = true
    global_position = position_to_paint
    var frames := _active_animation.sprite_frames
    var tex := frames.get_frame_texture(_active_animation.animation, _active_animation.frame)
    var native_size := tex.get_size()

    var ratio := size / native_size
    var uniform : float = min(ratio.x, ratio.y)   # fit inside the enemy's box
    _active_animation.scale = Vector2(uniform, uniform)
    _active_animation.play()
    if sound != null:
        sound.finished.connect(_on_sound_finished)
        sound.play()
    else:
        _is_sound_done = true


func _on_animation_completed() -> void:
    if _is_sound_done:
        animation_completed.emit()
        queue_free()
    else:
        _is_animation_done = true
        _active_animation.visible = false

func _on_sound_finished() -> void:
    if _is_animation_done:
        animation_completed.emit()
        queue_free()
    else:
        _is_sound_done = true
