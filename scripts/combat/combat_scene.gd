extends Control

@onready var player : EntityScene = %Player
@onready var enemy : EntityScene = %Enemy

var _player_stats : EntityStats
var _enemy_stats : EntityStats

@onready var _player_sprite : Texture2D = preload("res://assets/combat/player.png")
@onready var _enemy_sprite : Texture2D = preload("res://assets/combat/enemy.png")

@onready var _attack_button : Button = %AttackButton
@onready var _damage_button : Button = %DamageButton

@onready var _ability_grid : GridContainer = %AbilityGrid

var _ability_scene : PackedScene = preload("res://scenes/Combat/combat_ability.tscn")

func _ready() -> void:
	_player_stats = GameState.player_stats

	_enemy_stats = GameState.enemy_list.values().pick_random()

	player.init(_player_stats.max_health, _player_stats.armor, _player_stats.shield, _player_sprite )
	enemy.init(_enemy_stats.max_health, _enemy_stats.max_armor, _enemy_stats.max_shield, _enemy_sprite)

	_attack_button.pressed.connect(player.animate_attack)
	_damage_button.pressed.connect(enemy.animate_take_damage)

	for ability in GameState.player_abilities.values():
		var scene = _ability_scene.instantiate()
		_ability_grid.add_child(scene)
		scene.size_flags_horizontal = Control.SIZE_FILL
		scene.set_ability(ability.Name)
