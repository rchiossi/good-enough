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

@export var turn_indicator_offset : Vector2 = Vector2(0, -75)
@export var turn_indicator_speed : float = 0.3

@export var damage_font_size : int = 30
@export var damage_number_offset : Vector2 = Vector2(0, -100)
@export var damage_number_slide : int = -50
@export var damage_number_duration : float = 2.0
@export var damage_number_spread : int = 50

var _combat_tracker : CombatTracker = CombatTracker.new()

signal damage_animation_complete

func _ready() -> void:
	_player_stats = GameState.player_stats
	_player_stats.hp_changed.connect(_on_hp_changed.bind(_player_stats, player))
	_player_stats.armor_changed.connect(_on_armor_changed.bind(_player_stats, player))
	_player_stats.shield_changed.connect(_on_shield_changed.bind(_player_stats, player))
	_player_stats.damage_taken.connect(_on_damage_taken.bind(player))
	_player_stats.init()

	_enemy_stats = GameState.enemy_list.values().pick_random()
	_enemy_stats.hp_changed.connect(_on_hp_changed.bind(_enemy_stats, enemy))
	_enemy_stats.armor_changed.connect(_on_armor_changed.bind(_enemy_stats, enemy))
	_enemy_stats.shield_changed.connect(_on_shield_changed.bind(_enemy_stats, enemy))
	_enemy_stats.damage_taken.connect(_on_damage_taken.bind(enemy))
	_enemy_stats.init()

	player.init(_player_stats.max_health, _player_stats.armor, _player_stats.shield, _player_sprite )
	player.death_animation_complete.connect(on_player_death)

	enemy.init(_enemy_stats.max_health, _enemy_stats.max_armor, _enemy_stats.max_shield, _enemy_sprite)
	enemy.death_animation_complete.connect(on_enemy_death)

	_attack_button.pressed.connect(player.animate_attack)
	_damage_button.pressed.connect(enemy.animate_take_damage)
	_skip_button.pressed.connect(_skip_combat)

	for ability in _player_stats.abilities.values():
		var scene : CombatAbilityScene = _ability_scene.instantiate()
		_ability_grid.add_item(scene)
		scene.set_ability(ability.name)
		scene.show_tooltip.connect(_show_ability_info)
		scene.ability_activated.connect(_activate_ability)

	_ability_info.hide()

	var entities : Dictionary[String, EntityStats] = {}
	entities[_player_stats.name] = _player_stats
	entities[_enemy_stats.name] = _enemy_stats
	_combat_tracker.new_turn.connect(_on_new_turn)
	_combat_tracker.enemy_turn.connect(_on_enemy_turn)
	_combat_tracker.start_combat(entities, _player_stats)

	damage_animation_complete.connect(_combat_tracker.take_turn)

	_update_turn_indicator.call_deferred(false)

func _skip_combat():
	SceneLoader.load_scene("uid://clhtpadgac6l7")

func _show_ability_info(ability_name : String):
	_ability_info.set_ability(ability_name)

	_ability_info.show()

func _activate_ability(ability_name):
	if not _combat_tracker.is_active(_player_stats.name):
		return

	var ability : Ability = GameState.all_abilities[ability_name]

	_combat_tracker.step()
	_update_turn_indicator()

	_combat_tracker.take_action(ability.name, _enemy_stats)

func _on_enemy_turn():
	_combat_tracker.take_enemy_turn()
	_combat_tracker.step()
	_update_turn_indicator()

func _on_hp_changed(old_value: int, new_value: int, _stats: EntityStats, scene: EntityScene):
	scene.animate_health_bar(old_value, new_value)

	if new_value == 0:
		scene.animate_death()

func _on_armor_changed(old_value: int, new_value: int, _stats: EntityStats, scene: EntityScene):
	scene.animate_armor_bar(old_value, new_value)

func _on_shield_changed(old_value: int, new_value: int, _stats: EntityStats, scene: EntityScene):
	scene.animate_shield_bar(old_value, new_value)

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

	var tween = create_tween()
	tween.tween_interval(damage_number_duration)
	tween.tween_callback(_on_damage_animation_complete)

func _on_damage_animation_complete():
	damage_animation_complete.emit()

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
	if _combat_tracker.is_active(_player_stats.name):
		indicator_position = player.global_position + Vector2(player.size.x / 2, 0)
		print(player.global_position)
	else:
		indicator_position = enemy.global_position + Vector2(enemy.size.x / 2, 0)

	indicator_position += turn_indicator_offset

	_turn_indicator.show()

	if not animate:
		_turn_indicator.position = indicator_position
		return

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(_turn_indicator, "position", indicator_position, turn_indicator_speed)

func on_player_death():
	# TODO: Show Victory Popup
	SceneLoader.load_scene("uid://clhtpadgac6l7")

func on_enemy_death():
	# TODO: Show Defeat Poupup
	SceneLoader.load_scene("uid://clhtpadgac6l7")

func _on_new_turn(entity_name: String):
	pass
