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

signal animation_completed

var _is_sound_done = false
var _is_animation_done = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

func play(animation_type: Ability.AnimationType, position_to_paint : Vector2, size: Vector2):
    assert(animation_type != Ability.AnimationType.NONE)

    var animation : AnimatedSprite2D = null
    var sound : AudioStreamPlayer2D = null

    print("ANIMATION_TYPE=", animation_type)
    if animation_type == Ability.AnimationType.SUN_BLAST:
        animation = demon_bite_animation
    if animation_type == Ability.AnimationType.LIGHTNING_BOLT:
        sound = lightning_bolt_sound
        animation = lightning_bolt_animation
    if animation_type == Ability.AnimationType.CELESTIAL_BONK:
        sound = celestial_bonk_sound
        animation = celestial_bonk_animation
    if animation_type == Ability.AnimationType.FIRE_TORNADO:
        sound = fire_tornado_sound
        animation = fire_tornado_animation
    if animation_type == Ability.AnimationType.WATER_BLAST:
        sound = water_blast_sound
        animation = water_blast_animation
    if animation_type == Ability.AnimationType.WATER_SURGE:
        sound = water_surge_sound
        animation = water_surge_animation
    if animation_type == Ability.AnimationType.PHOENIX_FLAME:
        sound = phoenix_flame_sound
        animation = phoenix_flame_animation

    animation.animation_finished.connect(_on_animation_completed)

    animation.visible = true
    global_position = position_to_paint
    var frames := animation.sprite_frames
    var tex := frames.get_frame_texture(animation.animation, animation.frame)
    var native_size := tex.get_size()

    var ratio := size / native_size
    var uniform : float = min(ratio.x, ratio.y)   # fit inside the enemy's box
    animation.scale = Vector2(uniform, uniform)
    animation.play()
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

func _on_sound_finished() -> void:
    if _is_animation_done:
        animation_completed.emit()
        queue_free()
    else:
        _is_sound_done = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
