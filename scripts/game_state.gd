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
    reset()

func reset() -> void:
    _init_abilities()
    _init_player()
    _init_enemies()
    _reset_map()
    reset_state()

func _reset_map() -> void:
    map = {}
    current_position = Vector2i(0, 0)
    nodes = {}
    connections = {}

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
    var punch := Ability.new()
    punch.name = "Punch"
    punch.shield_damage = 2
    punch.armor_damage = 2
    punch.health_damage = 2
    punch.icon = preload("uid://ddpt2hr3n7xhd")
    punch.description = "You punch with all your might. Not your strongsuit, but hey. At least we deal some damage!"
    punch.cooldown = 0
    punch.ability_type = Ability.AbilityType.NORMAL
    _add_ability(punch)

    var fireball := Ability.new()
    fireball.name = "Fireball"
    fireball.shield_damage = 15
    fireball.armor_damage = 5
    fireball.health_damage = 5
    fireball.icon = preload("uid://n1peuh4vn6i0")
    fireball.description = "Some description"
    fireball.cooldown = 2
    fireball.ability_type = Ability.AbilityType.MAGIC
    _add_ability(fireball)

    var ice_dart := Ability.new()
    ice_dart.shield_damage = 25
    ice_dart.armor_damage = 0
    ice_dart.health_damage = 10
    ice_dart.name = "Ice Dart"
    ice_dart.icon = preload("uid://qscf336gkfa4")
    ice_dart.description = "An ice dart that shoots towards your enemy. Piercing them dealing significant magic damage, but fails to penetrate armor."
    ice_dart.cooldown = 3
    ice_dart.ability_type = Ability.AbilityType.MAGIC
    _add_ability(ice_dart)

    var visceral_bleed := Ability.new()
    visceral_bleed.shield_damage = 0
    visceral_bleed.armor_damage = 0
    visceral_bleed.health_damage = 25
    visceral_bleed.name = "Visceral Bleed"
    visceral_bleed.icon = preload("uid://bxm2bno0ekkfh")
    visceral_bleed.description = "You cut the veins of your enemies from the inside. Inflicts massive health damage."
    visceral_bleed.cooldown = 3
    visceral_bleed.ability_type = Ability.AbilityType.BLUNT
    _add_ability(visceral_bleed)

    var pillar_bonk := Ability.new()
    pillar_bonk.shield_damage = 0
    pillar_bonk.armor_damage = 40
    pillar_bonk.health_damage = 10
    pillar_bonk.name = "Pillar Bonk"
    pillar_bonk.icon = preload("uid://b4u3ocj05xk2e")
    pillar_bonk.description = "You smash a giant pillar onto the enemy. Dealing significant armor damage."
    pillar_bonk.cooldown = 5
    pillar_bonk.remaining_cooldown = 0
    pillar_bonk.ability_type = Ability.AbilityType.PIERCING
    _add_ability(pillar_bonk)

    var incinerate := Ability.new()
    incinerate.shield_damage = 30
    incinerate.armor_damage = 0
    incinerate.health_damage = 10
    incinerate.name = "Incinerate"
    incinerate.icon = preload("uid://5abb2wxisclh")
    incinerate.description = "You set your enemy on fire burning through their magical shield. This also affects health due to the severe heat."
    incinerate.cooldown = 3
    incinerate.ability_type = Ability.AbilityType.MAGIC
    _add_ability(incinerate)

    var blood_weave := Ability.new()
    blood_weave.shield_damage = 0
    blood_weave.armor_damage = 0
    blood_weave.health_damage = 50
    blood_weave.name = "Blood Weave"
    blood_weave.icon = preload("uid://dyxfch1jvsk5x")
    blood_weave.description = "You manipulate the blood of your enemies, causing it to leak into their muscle. Significantly damaging their ability to breathe."
    blood_weave.cooldown = 6
    blood_weave.ability_type = Ability.AbilityType.BLUNT
    _add_ability(blood_weave)
