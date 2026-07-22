extends Control

@onready var player : EntityScene = %Player
@onready var enemy : EntityScene = %Enemy

var _player_stats : EntityStats
var _enemy_stats : EntityStats

@onready var _player_sprite : Texture2D = preload("res://assets/combat/player.png")
@onready var _enemy_sprite : Texture2D = preload("res://assets/combat/enemy.png")

func _ready() -> void:
	_player_stats = GameState.player_stats

	_enemy_stats = EntityStats.new()

	player.init(_player_stats.max_health, _player_stats.armor, _player_stats.shield, _player_sprite )
	enemy.init(_enemy_stats.max_health, _enemy_stats.max_armor, _enemy_stats.max_shield, _enemy_sprite)
