extends Node

var all_abilities: Dictionary = {}
enum NodeTypes {
    Null,
    Start,
    Fight,
    Event,
    Count,
}

var map: Dictionary = {}
var current_position: Vector2i = Vector2i(0, 0)

var player_stats : EntityStats = EntityStats.new()
var player_abilities: Dictionary = {}

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

    player_stats.init()

func _init_enemies() -> void:
    var enemy = EntityStats.new()

    enemy.name = "Goblin"
    enemy.sprite = preload("res://assets/combat/enemy.png")
    enemy.max_health = 10
    enemy.max_armor = 10
    enemy.max_shield = 10
    enemy.init()

    enemy_list[enemy.name] = enemy

func reset_state() -> void:
    player_stats.init()

    current_turn = max_turns

func _add_ability(ability):
    all_abilities.get_or_add(ability.Name, ability)
    player_abilities.get_or_add(ability.Name, ability)

func _init_abilities():
    var fireball := Ability.new()
    fireball.Name = "Fireball"
    fireball.ShieldDamage = 15
    fireball.ArmorDamage = 5
    fireball.HealthDamage = 5
    fireball.Name = "Fireball"
    fireball.Icon = preload("uid://n1peuh4vn6i0")
    fireball.Description = "Some description"
    _add_ability(fireball)

    var ice_dart := Ability.new()
    ice_dart.ShieldDamage = 25
    ice_dart.ArmorDamage = 0
    ice_dart.HealthDamage = 10
    ice_dart.Name = "Ice Dart"
    ice_dart.Icon = preload("uid://qscf336gkfa4")
    ice_dart.Description = "An ice dart that shoots towards your enemy. Piercing them dealing significant magic damage, but fails to penetrate armor."
    _add_ability(ice_dart)

    var visceral_bleed := Ability.new()
    visceral_bleed.ShieldDamage = 0
    visceral_bleed.ArmorDamage = 0
    visceral_bleed.HealthDamage = 25
    visceral_bleed.Name = "Visceral Bleed"
    visceral_bleed.Icon = preload("uid://bxm2bno0ekkfh")
    visceral_bleed.Description = "You cut the veins of your enemies from the inside. Inflicts massive health damage."
    _add_ability(visceral_bleed)
