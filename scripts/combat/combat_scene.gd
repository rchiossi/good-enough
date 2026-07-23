extends Control

@onready var player : EntityScene = %Player
@onready var enemy : EntityScene = %Enemy

var _player_stats : EntityStats
var _enemy_stats : EntityStats

@onready var _player_sprite : Texture2D = preload("res://assets/combat/player.png")
@onready var _enemy_sprite : Texture2D = preload("res://assets/combat/enemy.png")

@onready var _attack_button : Button = %AttackButton
@onready var _damage_button : Button = %DamageButton
@onready var _skip_button : Button = %SkipCombatButton

@onready var _ability_grid : CombatAbilityGrid = %AbilityGrid
@onready var _ability_info : CombatAbilityTooltip = %AbilityInfo

var _ability_scene : PackedScene = preload("res://scenes/Combat/combat_ability.tscn")

@onready var _turn_indicator : TextureRect = %TurnIndicator

@onready var victory_panel : MarginContainer = %VictoryPanel
@onready var defeat_panel : MarginContainer = %DefeatPanel

@onready var screen_shake : AnimationScreenShake = %AnimationScreenShake

@export var end_battle_animation_duration : float = 0.5

@export var turn_indicator_offset : Vector2 = Vector2(0, -75)
@export var turn_indicator_speed : float = 0.3

@export var damage_font_size : int = 30
@export var damage_number_offset : Vector2 = Vector2(0, -100)
@export var damage_number_slide : int = -50
@export var damage_number_duration : float = 2.0
@export var damage_number_spread : int = 50


#var _combat_tracker : CombatTracker = CombatTracker.new()
var _combat_manager : CombatManager = CombatManager.new()
var _entity_scenes : Dictionary[String, EntityScene] = {}

func _ready() -> void:
    _player_stats = GameState.player_stats
    _player_stats.damage_taken.connect(_on_damage_taken.bind(player))
    _player_stats.init()

    _enemy_stats = GameState.enemy_list.values().pick_random()
    _enemy_stats.damage_taken.connect(_on_damage_taken.bind(enemy))
    _enemy_stats.init()

    player.init(_player_stats, _player_sprite )
    player.death_animation_complete.connect(_on_player_death)
    _entity_scenes[player.stats.name] = player

    enemy.init(_enemy_stats, _enemy_sprite)
    enemy.death_animation_complete.connect(_on_enemy_death)
    _entity_scenes[enemy.stats.name] = enemy

    load_abilities_to_grid()

    _ability_info.hide()

    # Debug Panel --
    _attack_button.pressed.connect(player.animate_attack)
    _damage_button.pressed.connect(enemy.animate_take_damage)
    _skip_button.pressed.connect(_skip_combat)
    # -------------

    var entities : Dictionary[String, EntityStats] = {}
    entities[_player_stats.name] = _player_stats
    entities[_enemy_stats.name] = _enemy_stats
    _combat_manager.state_changed.connect(_on_state_changed)
    _combat_manager.init_combat(entities, _player_stats.name)

    _animate_start_combat()


func load_abilities_to_grid():
    for ability in _player_stats.abilities.values():
        var scene : CombatAbilityScene = _ability_scene.instantiate()
        _ability_grid.add_item(scene)
        scene.set_ability(ability.name)
        scene.show_tooltip.connect(_show_ability_info)
        scene.ability_activated.connect(_activate_ability)

func _skip_combat():
    SceneLoader.load_scene("uid://clhtpadgac6l7")

func _show_ability_info(ability_name : String):
    _ability_info.set_ability(ability_name)

    _ability_info.show()

# Combat Flow --------------------

func _animate_start_combat():
    #TODO: Add something nice here
    _combat_manager.start_combat()

func _activate_ability(ability_name):
    if not _combat_manager.state == CombatManager.CombatState.WAITING_FOR_PLAYER_ACTION:
        return

    _combat_manager.take_player_action(ability_name,[enemy.stats.name])
    #This will trigger damage taken, which will call _on_damage_taken

func _on_damage_taken(shield_damage: int, armor_damage: int, hp_damage: int, scene: EntityScene):
    scene.animate_take_damage()

    if shield_damage != 0:
        var offset = Vector2(scene.size.x / 2 - damage_number_spread, 0)
        show_damage_numbers(shield_damage, Color.BLUE, offset, scene)

    if armor_damage != 0:
        var offset = Vector2(scene.size.x / 2, 0)
        show_damage_numbers(armor_damage, Color.GRAY, offset, scene)

    if hp_damage != 0:
        var offset = Vector2(scene.size.x / 2 + damage_number_spread, 0)
        show_damage_numbers(hp_damage, Color.RED, offset, scene)

    screen_shake.shake()

    var tween = create_tween()
    tween.tween_interval(damage_number_duration)
    if not scene.stats.is_player:
        tween.tween_callback(_on_player_animation_complete)
    else:
        tween.tween_callback(_on_enemy_animation_complete)

func _on_player_animation_complete():
    _combat_manager.conclude_player_action()

func _on_state_changed(state):
    match state:
        CombatManager.CombatState.WAITING_FOR_PLAYER_ACTION:
            _update_turn_indicator()
        CombatManager.CombatState.WAITING_FOR_ENEMY_ACTION:
            _update_turn_indicator()
        CombatManager.CombatState.COMBAT_ENDED:
            _play_death_animation()

func _on_enemy_animation_complete():
    _combat_manager.conclude_enemy_action()

func show_damage_numbers(value: int, color: Color, offset: Vector2, scene: EntityScene):
    var label = Label.new()
    label.text = str(value)

    label.label_settings = LabelSettings.new()
    label.label_settings.font_color = color
    label.label_settings.font_size = damage_font_size
    label.label_settings.outline_color = Color.BLACK

    label.offset_transform_enabled = true

    label.global_position = scene.global_position + damage_number_offset + offset
    label.z_index = 2

    add_child(label)

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)

    tween.tween_property(label, "offset_transform_position", Vector2(0, damage_number_slide), damage_number_duration)
    tween.parallel().tween_property(label, "modulate:a", 0.0, damage_number_duration)
    tween.tween_callback(func(): label.queue_free())

func _update_turn_indicator(animate : bool = true):
    var indicator_position : Vector2
    var active = _entity_scenes[_combat_manager.get_active_entity_name()]
    
    indicator_position = active.global_position + Vector2(active.size.x / 2, 0)
    indicator_position += turn_indicator_offset

    _turn_indicator.show()

    if not animate:
        _turn_indicator.position = indicator_position
        return

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_turn_indicator, "position", indicator_position, turn_indicator_speed)

func _play_death_animation():
    if player.stats.health == 0:
        player.animate_death()
    else:
        enemy.animate_death()

func _on_player_death():
    defeat_panel.modulate.a = 0.0
    defeat_panel.show()

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(defeat_panel, "modulate:a", 1.0, end_battle_animation_duration)

func _on_enemy_death():
    victory_panel.modulate.a = 0.0
    victory_panel.show()

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(victory_panel, "modulate:a", 1.0, end_battle_animation_duration)
