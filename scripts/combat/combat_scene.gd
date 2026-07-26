extends Control

@onready var player : EntityScene = %Player
@onready var enemy : EntityScene = %Enemy

var _player_stats : EntityStats
var _enemy_stats : EntityStats

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

@onready var _settings_panel : SettingsPanel = %SettingsPanel

@onready var _background : TextureRect = %Background

@onready var _hero_portrait : TextureRect = %HeroPortrait
@onready var _enemy_portrait : TextureRect = %EnemyPortrait

@onready var _bg_music : CombatBgMusic = %BgMusic

@onready var _battlelog_button : TextureButton = %BattleLogButton
@onready var _battlelog_panel : MarginContainer = %BattleLog
@onready var _battlelog_label : RichTextLabel = %BattleLogLabel
@onready var _battlelog_close_button : Button = %BattleLogCloseButton

@export var end_battle_animation_duration : float = 1.0

@export var turn_indicator_offset : Vector2 = Vector2(0, -25)
@export var turn_indicator_speed : float = 0.5

@export var damage_font_size : int = 30
@export var damage_number_offset : Vector2 = Vector2(0, -100)
@export var damage_number_slide : int = -50
@export var damage_number_duration : float = 2.0
@export var damage_number_spread : int = 50

@export var enemy_attack_delay : float = 2.0

@export var death_animation_delay : float = 1.0
var sprite_effect_scene: PackedScene = preload("uid://cxtb24nigdrwy")

var _game_stage : int = 1

var _backgrounds : Dictionary[String, Texture2D]= {
    "forest" : preload("uid://7uxcl0v0ljwg"),
    "castle_entrance": preload("uid://bq0ry2cdwpsse"),
    "castle_hall": preload("uid://bvn3beexnjjgw"),
    "throne_room": preload("uid://d2fkj7dowepop"),
}

var _combat_manager : CombatManager = CombatManager.new()
var _entity_scenes : Dictionary[String, EntityScene] = {}

func _ready() -> void:
    _calculate_game_stage()

    _load_music()

    _player_stats = GameState.player_stats
    _player_stats.damage_taken.connect(_on_damage_taken)
    _player_stats.heal_received.connect(_on_heal_received)
    _player_stats.init()

    _enemy_stats = GameState.enemy_list.values().filter(func(e): return e.stage == _game_stage).pick_random()
    _enemy_stats.damage_taken.connect(_on_damage_taken)
    _enemy_stats.heal_received.connect(_on_heal_received)
    _enemy_stats.init()

    player.init(_player_stats)
    _entity_scenes[player.stats.name] = player

    enemy.init(_enemy_stats)
    _entity_scenes[enemy.stats.name] = enemy

    _load_portraits()

    _load_abilities_to_grid()

    _ability_info.hide()

    _load_background()

    # Debug Panel --
    if GameState.DEBUG:
        $DebugContainer.visible = true
    _attack_button.pressed.connect(_play_death_animation)
    _damage_button.pressed.connect(enemy.animate_take_damage)
    _skip_button.pressed.connect(_skip_combat)
    # -------------

    _battlelog_button.pressed.connect(_show_battlelog)
    _battlelog_close_button.pressed.connect(_hide_battlelog)

    var entities : Dictionary[String, EntityStats] = {}
    entities[_player_stats.name] = _player_stats
    entities[_enemy_stats.name] = _enemy_stats
    _combat_manager.state_changed.connect(_on_state_changed)
    _combat_manager.new_turn.connect(_on_new_turn)
    _combat_manager.action_taken.connect(_on_action_taken)
    _combat_manager.new_event.connect(_on_new_combat_event)
    _combat_manager.init_combat(entities, _player_stats.name)

    _animate_start_combat.call_deferred()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if _battlelog_panel.visible:
            _battlelog_panel.hide()
        else:
            _settings_panel.fade_in()

func _calculate_game_stage():
    _game_stage = GameState.calculate_game_stage_for_turn(GameState.current_turn)

func _load_music():
    if _game_stage == 4:
        _bg_music._play_boss_phase_1()
    elif _game_stage == 5:
        _bg_music._play_boss_phase_2()
    else:
        _bg_music._play_normal()

func _on_new_turn(turn_count: int):
    if turn_count % 2 != 0:
        return

func _load_background():
    match _game_stage:
        1:
            _background.texture = _backgrounds["forest"]
        2:
            _background.texture = _backgrounds["castle_entrance"]
        3:
            _background.texture = _backgrounds["castle_hall"]
        4:
            _background.texture = _backgrounds["throne_room"]
        5:
            _background.texture = _backgrounds["throne_room"]

func _load_abilities_to_grid():
    for ability in _player_stats.abilities.values():
        var scene : CombatAbilityScene = _ability_scene.instantiate()
        _ability_grid.add_item(scene)
        scene.set_ability(ability.name)
        scene.show_tooltip.connect(_show_ability_info)
        scene.ability_hover.connect(_show_possible_dmg)
        scene.ability_hover_exit.connect(_hide_possible_dmg)
        if ability.is_disabled:
            scene.show_cursed()
        else:
            scene.hide_cursed()
            scene.ability_activated.connect(_activate_ability)

func _load_portraits():
    _hero_portrait.texture = _player_stats.portrait
    _enemy_portrait.texture = _enemy_stats.portrait

func _skip_combat():
    SceneLoader.load_scene("uid://bdqa7w342rmg8")

func _show_ability_info(ability_name : String):
    _ability_info.set_ability(ability_name)

    _ability_info.show()

func _show_possible_dmg(ability_name : StringName):
    var ability : Ability = GameState.all_abilities[ability_name]
    enemy.possible_damage.emit(ability.health_damage, ability.armor_damage, ability.shield_damage)

func _hide_possible_dmg():
    enemy.clear_damage_indication()

# Combat Flow --------------------

func _animate_start_combat():
    #TODO: Add something nice here
    if not player.is_node_ready():
        await get_tree().process_frame
    _combat_manager.start_combat()

func _activate_ability(ability_name):
    if not _combat_manager.state == CombatManager.CombatState.WAITING_FOR_PLAYER_ACTION:
        return

    _combat_manager.take_player_action(ability_name,[enemy.stats.name])
    _update_turn_indicator(enemy.stats.name)
    _update_abilities_cooldown()
    #This will trigger damage taken, which will call _on_damage_taken

func _on_damage_taken(source: EntityStats, target: EntityStats, shield_damage: int, armor_damage: int, hp_damage: int, _ability_name: String):
    var target_scene = _entity_scenes[target.name]

    target_scene.animate_take_damage()

    if shield_damage != 0:
        var offset = Vector2(target_scene.size.x / 2 - damage_number_spread, 0)
        show_damage_numbers(shield_damage, Color.BLUE, offset, target_scene)

    if armor_damage != 0:
        var offset = Vector2(target_scene.size.x / 2, 0)
        show_damage_numbers(armor_damage, Color.GRAY, offset, target_scene)

    if hp_damage != 0:
        var offset = Vector2(target_scene.size.x / 2 + damage_number_spread, 0)
        show_damage_numbers(hp_damage, Color.RED, offset, target_scene)

    screen_shake.shake()

    var tween = create_tween()
    tween.tween_interval(turn_indicator_speed)
    if source.is_player:
        tween.tween_callback(_on_player_animation_complete)
    else:
        tween.tween_callback(_on_enemy_animation_complete)

func _on_heal_received(source: EntityStats, _target: EntityStats, shield_regen: int, armor_regen: int, hp_regen: int, _ability_name: String):
    print("On heal received")
    var source_scene = _entity_scenes[source.name]

    source_scene.animate_receive_heal()

    if shield_regen != 0:
        var offset = Vector2(source_scene.size.x / 2 - damage_number_spread, 0)
        show_damage_numbers(shield_regen, Color.LIGHT_BLUE, offset, source_scene)

    if armor_regen != 0:
        var offset = Vector2(source_scene.size.x / 2, 0)
        show_damage_numbers(armor_regen, Color.LIGHT_GRAY, offset, source_scene)

    if hp_regen != 0:
        var offset = Vector2(source_scene.size.x / 2 + damage_number_spread, 0)
        show_damage_numbers(hp_regen, Color.LIGHT_SALMON, offset, source_scene)

    var tween = create_tween()
    tween.tween_interval(turn_indicator_speed)
    if source.is_player:
        tween.tween_callback(_on_player_animation_complete)
    else:
        tween.tween_callback(_on_enemy_animation_complete)

func _on_player_animation_complete():
    _combat_manager.conclude_player_action()

func _on_state_changed(state):
    match state:
        CombatManager.CombatState.WAITING_FOR_PLAYER_ACTION:
            _enable_abilities_highlight()
            if not _turn_indicator.visible:
                _update_turn_indicator(player.stats.name)
        CombatManager.CombatState.WAITING_FOR_ENEMY_ACTION:
            _clear_abilities_highlights()

            var tween = create_tween()
            tween.tween_interval(enemy_attack_delay)
            tween.tween_callback(_combat_manager.take_enemy_action)
        CombatManager.CombatState.ENEMY_ACTION_STARTED:
            _update_turn_indicator(player.stats.name)
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

func _update_turn_indicator(target_name: String):
    var indicator_position : Vector2
    var target = _entity_scenes[target_name]
    
    indicator_position = target.global_position + Vector2(target.size.x / 2, 0) - _turn_indicator.size / 2
    indicator_position += turn_indicator_offset

    if not _turn_indicator.visible:
        _turn_indicator.show()
        _turn_indicator.position = indicator_position
        return

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_turn_indicator, "position", indicator_position, turn_indicator_speed)

func _play_ability_effect(target: EntityScene, ability: Ability, with_blood: bool = true):
    if ability.animation_type != Ability.AnimationType.NONE:
        var sprite_effect: SunStrikeAnimation = sprite_effect_scene.instantiate()
        add_child(sprite_effect)
        sprite_effect.play(ability.animation_type, target.global_position + target.size / 2, target.size)

    if not with_blood:

        return
    var effect : GPUParticles2D = ability.effect_scene.instantiate()
    effect.global_position = target.global_position + target.size / 2
    effect.emitting = true
    effect.finished.connect(effect.queue_free)

    add_child(effect)
#    move_child(effect, target.get_index())

func _update_abilities_cooldown():
    for ability in GameState.player_stats.abilities.values():
        if ability.is_disabled:
            ability.remaining_cooldown[GameState.player_stats.name] -= 0

        var cooldown = ability.remaining_cooldown.get_or_add(GameState.player_stats.name, 0)
        if cooldown > 0:
            ability.remaining_cooldown[GameState.player_stats.name] -= 1
    _ability_grid.update_abilities()

func _play_death_animation():
    if player.stats.health == 0:
        player.animate_death()
    else:
        enemy.animate_death()

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_background, "material:shader_parameter/flash_percentage", 1.0, 0.5)
    tween.tween_interval(death_animation_delay)
    tween.tween_callback(_on_death)

func _play_reverse_death_animation():
    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_background, "material:shader_parameter/flash_percentage", 0.1, 1.0)
    tween.tween_property(_background, "material:shader_parameter/flash_color", Color("#eff29b"), 1.0)

func _on_death():
    var end_panel : MarginContainer
    if player.stats.health == 0:
        end_panel = defeat_panel
    else:
        if _game_stage == 4:
            _load_boss_phase2()
            return
        if _game_stage == 5:
            SceneLoader.load_scene("uid://106t2sncjqc7")
            return

        end_panel = victory_panel
    
    end_panel.show()

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_SINE)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(end_panel, "modulate:a", 1.0, end_battle_animation_duration)

func _on_action_taken(_source_name: String, target_name: String, ability_name: String):
    var ability = GameState.all_abilities[ability_name]
    var source = _entity_scenes[_source_name]
    var target = _entity_scenes[target_name]

    if ability.has_heals():
        _play_ability_effect(source, ability, false)
    else:
        _play_ability_effect(target, ability)


func _load_boss_phase2():
    _game_stage = 5

    _load_music()

    _enemy_stats = GameState.enemy_list.values().filter(func(e): return e.stage == _game_stage).pick_random()
    _enemy_stats.damage_taken.connect(_on_damage_taken)
    _enemy_stats.heal_received.connect(_on_heal_received)
    _enemy_stats.init()

    enemy.init(_enemy_stats, true)
    _entity_scenes[enemy.stats.name] = enemy

    _load_portraits()

    var entities : Dictionary[String, EntityStats] = {}
    entities[_player_stats.name] = _player_stats
    entities[_enemy_stats.name] = _enemy_stats
    _combat_manager.init_combat(entities, _player_stats.name, true)

    enemy.reverse_death_complete.connect(_proceed_with_phase2)

    _update_turn_indicator(_player_stats.name)

    enemy.animate_reverse_death()

func _proceed_with_phase2():
    _play_reverse_death_animation()
    _animate_start_combat.call_deferred()

func _enable_abilities_highlight():
    for scene : CombatAbilityScene in _ability_grid.ability_scenes:
        var ability : Ability = GameState.all_abilities[scene._ability_name]
        if ability.remaining_cooldown[_player_stats.name] != 0:
            continue 

        if ability.is_disabled:
            continue

        if _combat_manager.can_damage(ability, _enemy_stats):
            scene.enable_highlight()
        elif ability.has_heals():
            scene.enable_highlight()

func _clear_abilities_highlights():
    for scene : CombatAbilityScene in _ability_grid.ability_scenes:
        scene.disable_highlight()

func _show_battlelog():
    # var text : String = ""

    # for event in _combat_manager.combat_events:
    #     text += " - "
    #     text += event.source.name
    #     text += " casted " + event.ability.name
    #     text += " on " + event.target.name
    #     text += " dealing " + str(event.shield_damage) + "a,"
    #     text += str(event.armor_damage) + "a,"
    #     text += str(event.hp_damage) + "h damage.\n"

    # _battlelog_label.text = text

    _battlelog_panel.show()

func _hide_battlelog():
    _battlelog_panel.hide()

func _on_new_combat_event(event: CombatEvent):

    if event.ability.has_heals():
        if event.source.name == _player_stats.name:
            _battlelog_label.append_text(" - [color=#4ca180]%s[/color] used [color=#e3ae52]%s[/color] " %
                [event.source.name, event.ability.name])
        else:
            _battlelog_label.append_text(" - [color=#ba75a6]%s[/color] used [color=#e3ae52]%s[/color] " %
                [event.source.name, event.ability.name])

        _battlelog_label.append_text("healing ")

        if event.shield_change != 0:
            _battlelog_label.append_text("[color=#5275a3]%d shield[/color] " % [event.shield_change])
        if event.armor_change != 0:
            _battlelog_label.append_text("[color=#e3d5af]%d armor[/color] " % [event.armor_change])
        if event.hp_change != 0:
            _battlelog_label.append_text("[color=#b34947]%d health[/color] " % [event.hp_change])

        _battlelog_label.append_text(".\n")
    else:
        if event.source.name == _player_stats.name:
            _battlelog_label.append_text(" - [color=#4ca180]%s[/color] used [color=#e3ae52]%s[/color] on [color=#ba75a6]%s[/color] " %
                [event.source.name, event.ability.name, event.target.name])
        else:
            _battlelog_label.append_text(" - [color=#ba75a6]%s[/color] used [color=#e3ae52]%s[/color] on [color=#4ca180]%s[/color] " %
                [event.source.name, event.ability.name, event.target.name])

        _battlelog_label.append_text("dealing ")

        if event.shield_change != 0:
            _battlelog_label.append_text("[color=#5275a3]%d shield[/color] " % [event.shield_change])
        if event.armor_change != 0:
            _battlelog_label.append_text("[color=#e3d5af]%d armor[/color] " % [event.armor_change])
        if event.hp_change != 0:
            _battlelog_label.append_text("[color=#b34947]%d health[/color] " % [event.hp_change])

        _battlelog_label.append_text("damage.\n")
    
