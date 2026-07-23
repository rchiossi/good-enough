extends Node

var all_abilities: Dictionary[String, Ability] = {}
enum NodeTypes {
	Null,
	Start,
	Fight,
	Event,
	Count,
}

var map: Dictionary = {}
var current_position: Vector2i = Vector2i(0, 0)
var nodes: Dictionary[Vector2i, MapChoiceButton] = {}
var connections: Dictionary[Vector2i, Dictionary] = {}

var player_stats : EntityStats = EntityStats.new()

const max_turns : int = 10
var current_turn : int

const player_health : int = 100
const player_armor : int = 100
const player_shield : int = 100

var enemy_list : Dictionary = {}

func _ready() -> void:
	_init_abilities()
	_init_player()
	_init_enemies()
	reset_state()

func _init_player() -> void:
	player_stats.name = "Player"
	player_stats.sprite = preload("res://assets/combat/player.png")
	player_stats.max_health = player_health
	player_stats.max_armor = player_armor
	player_stats.max_shield = player_shield
	player_stats.is_player = true

	for ability in all_abilities.values():
		player_stats.abilities[ability.name] = ability

	player_stats.init()

func _init_enemies() -> void:
	var enemy = EntityStats.new()

	enemy.name = "Goblin"
	enemy.sprite = preload("res://assets/combat/enemy.png")
	enemy.max_health = 10
	enemy.max_armor = 10
	enemy.max_shield = 10
	enemy.is_player = false
	#TODO: Add proper abilities
	var ability = all_abilities.values()[0]
	enemy.abilities[ability.name] = ability
	enemy.init()

	enemy_list[enemy.name] = enemy

func reset_state() -> void:
	player_stats.init()

	current_turn = max_turns

func _add_ability(ability):
	all_abilities.get_or_add(ability.name, ability)

func _init_abilities():
	var fireball := Ability.new()
	fireball.name = "Fireball"
	fireball.shield_damage = 15
	fireball.armor_damage = 5
	fireball.health_damage = 5
	fireball.name = "Fireball"
	fireball.icon = preload("uid://n1peuh4vn6i0")
	fireball.description = "Some description"
	fireball.cooldown = 1
	_add_ability(fireball)

	var ice_dart := Ability.new()
	ice_dart.shield_damage = 25
	ice_dart.armor_damage = 0
	ice_dart.health_damage = 10
	ice_dart.name = "Ice Dart"
	ice_dart.icon = preload("uid://qscf336gkfa4")
	ice_dart.description = "An ice dart that shoots towards your enemy. Piercing them dealing significant magic damage, but fails to penetrate armor."
	ice_dart.cooldown = 2
	_add_ability(ice_dart)

	var visceral_bleed := Ability.new()
	visceral_bleed.shield_damage = 0
	visceral_bleed.armor_damage = 0
	visceral_bleed.health_damage = 25
	visceral_bleed.name = "Visceral Bleed"
	visceral_bleed.icon = preload("uid://bxm2bno0ekkfh")
	visceral_bleed.description = "You cut the veins of your enemies from the inside. Inflicts massive health damage."
	visceral_bleed.cooldown = 3
	_add_ability(visceral_bleed)
