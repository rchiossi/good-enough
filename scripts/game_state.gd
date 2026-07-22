extends Node

var player_stats : EntityStats = EntityStats.new()
var player_abilities: Array = [
	Fireball.new()
]

const max_turns : int = 10
var current_turn : int

const player_health : int = 100
const player_armor : int = 100
const player_shield : int = 100

var enemy_list : Dictionary = {}

func _ready() -> void:

	_init_player()
	_init_enemies()

	reset_state()

func _init_player() -> void:
	player_stats.name = "Player"

	player_stats.max_health = player_health
	player_stats.max_armor = player_armor
	player_stats.max_shield = player_shield

	player_stats.init()

func _init_enemies() -> void:
	var enemy = EntityStats.new()

	enemy.name = "Goblin"
	enemy.max_health = 10
	enemy.max_armor = 10
	enemy.max_shield = 10
	enemy.init()

	enemy_list[enemy.name] = enemy

func reset_state() -> void:
	player_stats.init()

	current_turn = max_turns
