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
var current_position: Vector2i = Vector2i(-1, -1)
var nodes: Dictionary[Vector2i, MapChoiceButton] = {}
var connections: Dictionary[Vector2i, Dictionary] = {}

var player_stats : EntityStats = EntityStats.new()

const max_turns : int = 10
var current_turn : int = -1

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
    current_position = Vector2i(-1, -1)
    nodes = {}
    connections = {}

func _init_player() -> void:
    player_stats.name = "Player"
    player_stats.sprite = preload("uid://d0p6syokv5sd7")
    player_stats.portrait = preload("uid://b6vdmyguytleb")
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
    enemy.sprite = preload("uid://bihigvwvvgnm3")
    enemy.portrait = preload("uid://7kdx45dvnur8")
    enemy.max_health = 10
    enemy.max_armor = 5
    enemy.max_shield = 0
    enemy.is_player = false
    enemy.stage = 1
    _register_ability(enemy, "Punch")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Wolf"
    enemy.sprite = preload("uid://catthopdua8g4")
    enemy.portrait = preload("uid://bniyhx2w6u431")
    enemy.max_health = 15
    enemy.max_armor = 10
    enemy.max_shield = 10
    enemy.is_player = false
    enemy.stage = 1
    _register_ability(enemy, "Punch")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Skeleton"
    enemy.sprite = preload("uid://dyjemcig3qw8q")
    enemy.portrait = preload("uid://erkrb87cardp")
    enemy.max_health = 5
    enemy.max_armor = 5
    enemy.max_shield = 5
    enemy.is_player = false
    enemy.stage = 1
    _register_ability(enemy, "Punch")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Skeletal Sludge"
    enemy.sprite = preload("uid://bs6dmy37eey6f")
    enemy.portrait = preload("uid://6ocbbtxsmq4e")
    enemy.max_health = 50
    enemy.max_armor = 0
    enemy.max_shield = 30
    enemy.is_player = false
    enemy.stage = 2
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Fireball")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Wraith"
    enemy.sprite = preload("uid://i8x6ipktxrdk")
    enemy.portrait = preload("uid://xjyskh6ypqon")
    enemy.max_health = 30
    enemy.max_armor = 10
    enemy.max_shield = 50
    enemy.is_player = false
    enemy.stage = 2
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Visceral Bleed")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Cursed Book"
    enemy.sprite = preload("uid://wuhsiig2xuve")
    enemy.portrait = preload("uid://ct82304pdnvs3")
    enemy.max_health = 10
    enemy.max_armor = 70
    enemy.max_shield = 20
    enemy.is_player = false
    enemy.stage = 2
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Incinerate")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Cthulu"
    enemy.sprite = preload("uid://1q2o5e4hg3hx")
    enemy.portrait = preload("uid://ccjo8vvetkel0")
    enemy.max_health = 200
    enemy.max_armor = 100
    enemy.max_shield = 200
    enemy.is_player = false
    enemy.stage = 3
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Blood Weave")
    _register_ability(enemy, "Fireball")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Death Warrior"
    enemy.sprite = preload("uid://dolrgr2cb6kqm")
    enemy.portrait = preload("uid://berxvfyr26g1t")
    enemy.max_health = 300
    enemy.max_armor = 200
    enemy.max_shield = 0
    enemy.is_player = false
    enemy.stage = 3
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Ice Dart")
    _register_ability(enemy, "Incinerate")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Lich"
    enemy.sprite = preload("uid://cgpdln8c2xrdl")
    enemy.portrait = preload("uid://cio1h6ddhn6hs")
    enemy.max_health = 50
    enemy.max_armor = 200
    enemy.max_shield = 250
    enemy.is_player = false
    enemy.stage = 3
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Ice Dart")
    _register_ability(enemy, "Fireball")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Ct. Downcula"
    enemy.sprite = preload("uid://bd4t8mmbdxtrh")
    enemy.portrait = preload("uid://cs2oqgrjhj011")
    enemy.max_health = 500
    enemy.max_armor = 200
    enemy.max_shield = 200
    enemy.is_player = false
    enemy.stage = 4
    _register_ability(enemy, "Fireball")
    _register_ability(enemy, "Ice Dart")
    _register_ability(enemy, "Visceral Bleed")
    _register_ability(enemy, "Incinerate")
    _register_ability(enemy, "Blood Weave")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Downcula"
    enemy.sprite = preload("uid://4i6y012x84ag")
    enemy.portrait = preload("uid://bndiawknicwyq")
    enemy.max_health = 1000
    enemy.max_armor = 1000
    enemy.max_shield = 0
    enemy.is_player = false
    enemy.stage = 5
    _register_ability(enemy, "Incinerate")
    _register_ability(enemy, "Pillar Bonk")
    enemy.init()
    enemy_list[enemy.name] = enemy

func _register_ability(enemy: EntityStats, ability_name: String):
    var ability = all_abilities[ability_name]
    enemy.abilities[ability.name] = ability

func reset_state() -> void:
    player_stats.init()

    current_turn = -1

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
