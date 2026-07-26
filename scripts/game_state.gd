extends Node

var all_abilities: Dictionary[String, Ability] = {}
enum NodeTypes {
    Null,
    Start,
    Fight,
    Event,
    Count,
}

var used_events: Array[int] = []

var map: Dictionary = {}
var current_position: Vector2i = Vector2i(-1, -1)
var nodes: Dictionary[Vector2i, MapChoiceButton] = {}
var connections: Dictionary[Vector2i, Dictionary] = {}

var color_enabled: Color = Color("#5bb362")
var color_disabled: Color = Color("#b34947")
var color_highlight: Color = Color("#5275a3")

var player_stats : EntityStats = EntityStats.new()

const max_turns : int = 10
var current_turn : int = -1

const player_health : int = 150
const player_armor : int = 200
const player_shield : int = 100

var enemy_list : Dictionary[StringName, EntityStats] = {}

var DEBUG: bool = false

var health_scale = {
    1: [2, 2, 2],
    2: [2.5, 2.5, 2.5],
    3: [1.75, 1.75, 1.75],
    4: [0.75, 0.75, 0.75],
    5: [0.5, 0.5, 0.5],
}

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
    player_stats = EntityStats.new()
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
    enemy.max_health = 30
    enemy.max_armor = 60
    enemy.max_shield = 0
    enemy.is_player = false
    enemy.stage = 1
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Cursed Explosion")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Wolf"
    enemy.sprite = preload("uid://catthopdua8g4")
    enemy.portrait = preload("uid://bniyhx2w6u431")
    enemy.max_health = 70
    enemy.max_armor = 20
    enemy.max_shield = 0
    enemy.is_player = false
    enemy.stage = 1
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Fury Tornado")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Skeleton"
    enemy.sprite = preload("uid://dyjemcig3qw8q")
    enemy.portrait = preload("uid://erkrb87cardp")
    enemy.max_health = 30
    enemy.max_armor = 0
    enemy.max_shield = 60
    enemy.is_player = false
    enemy.stage = 1
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Ice Dart")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Skeletal Sludge"
    enemy.sprite = preload("uid://bs6dmy37eey6f")
    enemy.portrait = preload("uid://6ocbbtxsmq4e")
    enemy.max_health = 180
    enemy.max_armor = 0
    enemy.max_shield = 90
    enemy.is_player = false
    enemy.stage = 2
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Cursed Explosion")
    _register_ability(enemy, "Fury Tornado")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Wraith"
    enemy.sprite = preload("uid://i8x6ipktxrdk")
    enemy.portrait = preload("uid://xjyskh6ypqon")
    enemy.max_health = 90
    enemy.max_armor = 60
    enemy.max_shield = 120
    enemy.is_player = false
    enemy.stage = 2
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Visceral Bleed")
    _register_ability(enemy, "Frost Tomb")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Cursed Book"
    enemy.sprite = preload("uid://wuhsiig2xuve")
    enemy.portrait = preload("uid://ct82304pdnvs3")
    enemy.max_health = 40
    enemy.max_armor = 140
    enemy.max_shield = 90
    enemy.is_player = false
    enemy.stage = 2
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Incinerate")
    _register_ability(enemy, "Cursed Explosion")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Cthulu"
    enemy.sprite = preload("uid://1q2o5e4hg3hx")
    enemy.portrait = preload("uid://ccjo8vvetkel0")
    enemy.max_health = 200
    enemy.max_armor = 50
    enemy.max_shield = 200
    enemy.is_player = false
    enemy.stage = 3
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Abyssal Pain")
    _register_ability(enemy, "Cursed Explosion")
    _register_ability(enemy, "Fury Tornado")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Death Warrior"
    enemy.sprite = preload("uid://dolrgr2cb6kqm")
    enemy.portrait = preload("uid://berxvfyr26g1t")
    enemy.max_health = 250
    enemy.max_armor = 200
    enemy.max_shield = 0
    enemy.is_player = false
    enemy.stage = 3
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Ice Dart")
    _register_ability(enemy, "Incinerate")
    _register_ability(enemy, "Fury Tornado")
    enemy.init()
    enemy_list[enemy.name] = enemy

    enemy = EntityStats.new()
    enemy.name = "Lich"
    enemy.sprite = preload("uid://cgpdln8c2xrdl")
    enemy.portrait = preload("uid://cio1h6ddhn6hs")
    enemy.max_health = 50
    enemy.max_armor = 200
    enemy.max_shield = 200
    enemy.is_player = false
    enemy.stage = 3
    _register_ability(enemy, "Punch")
    _register_ability(enemy, "Ice Dart")
    _register_ability(enemy, "Cursed Explosion")
    _register_ability(enemy, "Ligthning Bolt")
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
    _register_ability(enemy, "Cursed Explosion")
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
    _register_ability(enemy, "Fury Tornado")
    _register_ability(enemy, "Cursed Explosion")
    enemy.init()
    enemy_list[enemy.name] = enemy
    
    for en in enemy_list.values():
        var scales = health_scale.get(en.stage, [1, 1, 1])
        en.max_health = en.max_health * scales[0]
        en.max_armor = en.max_armor * scales[1]
        en.max_shield = en.max_shield * scales[2]

func _register_ability(enemy: EntityStats, ability_name: String):
    var ability = all_abilities[ability_name]
    enemy.abilities[ability.name] = ability

func reset_state() -> void:
    player_stats.init()

    current_turn = -1

func _add_ability(ability):
    all_abilities.get_or_add(ability.name, ability)

func _init_abilities():
    all_abilities.clear()
    var punch := Ability.new()
    punch.name = "Punch"
    punch.shield_damage = 10
    punch.armor_damage = 10
    punch.health_damage = 10
    punch.icon = preload("uid://ddpt2hr3n7xhd")
    punch.description = "You punch with all your might. Not your strongsuit, but hey. At least we deal some damage!"
    punch.cooldown = 0
    punch.ability_type = Ability.AbilityType.NORMAL
    _add_ability(punch)

    var cursed_explosion := Ability.new()
    cursed_explosion.name = "Cursed Explosion"
    cursed_explosion.shield_damage = 75
    cursed_explosion.armor_damage = 25
    cursed_explosion.health_damage = 25
    cursed_explosion.icon = preload("uid://du33uf7su8cdy")
    cursed_explosion.description = "An explosive curse is unleashed upon your enemy."
    cursed_explosion.cooldown = 4
    cursed_explosion.ability_type = Ability.AbilityType.MAGIC
    cursed_explosion.animation_type = Ability.AnimationType.DARK_SPIKE_EXPLOSION
    _add_ability(cursed_explosion)

    var ice_dart := Ability.new()
    ice_dart.shield_damage = 125
    ice_dart.armor_damage = 0
    ice_dart.health_damage = 50
    ice_dart.name = "Ice Dart"
    ice_dart.icon = preload("uid://qscf336gkfa4")
    ice_dart.description = "An ice dart that shoots towards your enemy. Piercing them dealing significant magic damage, but fails to penetrate armor."
    ice_dart.cooldown = 3
    ice_dart.ability_type = Ability.AbilityType.MAGIC
    ice_dart.animation_type = Ability.AnimationType.ICE_DART
    _add_ability(ice_dart)

    var visceral_bleed := Ability.new()
    visceral_bleed.shield_damage = 0
    visceral_bleed.armor_damage = 0
    visceral_bleed.health_damage = 125
    visceral_bleed.name = "Visceral Bleed"
    visceral_bleed.icon = preload("uid://bxm2bno0ekkfh")
    visceral_bleed.description = "You cut the veins of your enemies from the inside. Inflicts massive health damage."
    visceral_bleed.cooldown = 3
    visceral_bleed.ability_type = Ability.AbilityType.BLUNT
    visceral_bleed.animation_type = Ability.AnimationType.BLOOD_BEND_MEDIUM
    _add_ability(visceral_bleed)

    var pillar_bonk := Ability.new()
    pillar_bonk.shield_damage = 0
    pillar_bonk.armor_damage = 200
    pillar_bonk.health_damage = 50
    pillar_bonk.name = "Pillar Bonk"
    pillar_bonk.icon = preload("uid://b4u3ocj05xk2e")
    pillar_bonk.description = "You smash a giant pillar onto the enemy. Dealing significant armor damage."
    pillar_bonk.cooldown = 5
    pillar_bonk.ability_type = Ability.AbilityType.PIERCING
    pillar_bonk.animation_type = Ability.AnimationType.CELESTIAL_BONK
    _add_ability(pillar_bonk)

    var incinerate := Ability.new()
    incinerate.shield_damage = 150
    incinerate.armor_damage = 0
    incinerate.health_damage = 50
    incinerate.name = "Incinerate"
    incinerate.icon = preload("uid://5abb2wxisclh")
    incinerate.description = "You set your enemy on fire burning through their magical shield. This also affects health due to the severe heat."
    incinerate.cooldown = 3
    incinerate.ability_type = Ability.AbilityType.MAGIC
    incinerate.animation_type = Ability.AnimationType.FIRE_TORNADO
    _add_ability(incinerate)

    var blood_weave := Ability.new()
    blood_weave.shield_damage = 0
    blood_weave.armor_damage = 0
    blood_weave.health_damage = 250
    blood_weave.name = "Blood Weave"
    blood_weave.icon = preload("uid://dyxfch1jvsk5x")
    blood_weave.description = "You manipulate the blood of your enemies, causing it to leak into their muscle. Significantly damaging their ability to breathe."
    blood_weave.cooldown = 6
    blood_weave.ability_type = Ability.AbilityType.BLUNT
    blood_weave.animation_type = Ability.AnimationType.BLOOD_BEND_BIG
    _add_ability(blood_weave)

    var frost_tomb := Ability.new()
    frost_tomb.health_damage = 25
    frost_tomb.shield_damage = 250
    frost_tomb.name = "Frost Tomb"
    frost_tomb.icon = preload("uid://cm8yuipv7sih1")
    frost_tomb.description = "You create a large frost tomb and trap your enemy."
    frost_tomb.cooldown = 4
    frost_tomb.ability_type = Ability.AbilityType.MAGIC
    frost_tomb.animation_type = Ability.AnimationType.FROST_TOMB
    _add_ability(frost_tomb)

    var phoenix_flame := Ability.new()
    phoenix_flame.health_damage = 0
    phoenix_flame.armor_damage = 200
    phoenix_flame.shield_damage = 0
    phoenix_flame.name = "Phoenix Flame"
    phoenix_flame.icon = preload("uid://dcqtsgnni83fl")
    phoenix_flame.description = "You summon the fire of a phoenix, causing damage to your enemy."
    phoenix_flame.cooldown = 4
    phoenix_flame.ability_type = Ability.AbilityType.PIERCING
    phoenix_flame.animation_type = Ability.AnimationType.PHOENIX_FLAME
    _add_ability(phoenix_flame)

    var heal_wounds := Ability.new()
    heal_wounds.health_regeneration = 250
    heal_wounds.name = "Heal Wounds"
    heal_wounds.icon = preload("uid://bmotw7e36xw2m")
    heal_wounds.description = "You take a moment to heal your deepest wounds. Significantly restoring health."
    heal_wounds.cooldown = 8
    heal_wounds.ability_type = Ability.AbilityType.MAGIC
    heal_wounds.animation_type = Ability.AnimationType.HEAL
    _add_ability(heal_wounds)

    var quick_mend := Ability.new()
    quick_mend.health_regeneration = 0
    quick_mend.shield_regeneration = 0
    quick_mend.armor_regeneration = 250
    quick_mend.name = "Mend Armor"
    quick_mend.icon = preload("uid://5jahvm77bwuj")
    quick_mend.description = "You fix your armor, prepared to take more blows."
    quick_mend.cooldown = 5
    quick_mend.ability_type = Ability.AbilityType.MAGIC
    quick_mend.animation_type = Ability.AnimationType.HEAL_ARMOR
    _add_ability(quick_mend)

    var lightning_bolt := Ability.new()
    lightning_bolt.shield_damage = 250
    lightning_bolt.armor_damage = 100
    lightning_bolt.name = "Ligthning Bolt"
    lightning_bolt.icon = preload("uid://386kl84jfkoh")
    lightning_bolt.description = "The clouds darken, the hollowing noise of the wind and clouds are followed by a flash and a loud explosion."
    lightning_bolt.cooldown = 7
    lightning_bolt.ability_type = Ability.AbilityType.MAGIC
    lightning_bolt.animation_type = Ability.AnimationType.LIGHTNING_BOLT
    _add_ability(lightning_bolt)

    var water_canon := Ability.new()
    water_canon.shield_damage = 50
    water_canon.armor_damage = 125
    water_canon.health_damage = 25
    water_canon.name = "Water Canon"
    water_canon.icon = preload("uid://012has2563fj")
    water_canon.cooldown = 4
    water_canon.ability_type = Ability.AbilityType.PIERCING
    water_canon.animation_type = Ability.AnimationType.WATER_BLAST
    _add_ability(water_canon)

    var water_surge := Ability.new()
    water_surge.shield_damage = 75
    water_surge.armor_damage = 100
    water_surge.health_damage = 0
    water_surge.name = "Water Surge"
    water_surge.icon = preload("uid://dfdql4dj4hdm7")
    water_surge.cooldown = 3
    water_surge.ability_type = Ability.AbilityType.PIERCING
    water_surge.animation_type = Ability.AnimationType.WATER_SURGE
    _add_ability(water_surge)

    var abyssal_pain := Ability.new()
    abyssal_pain.shield_damage = 125
    abyssal_pain.armor_damage = 225
    abyssal_pain.health_damage = 0
    abyssal_pain.name = "Abyssal Pain"
    abyssal_pain.icon = preload("uid://3y2w3lbr8rck")
    abyssal_pain.description = "You forge a magical pain onto your enemy."
    abyssal_pain.cooldown = 5
    abyssal_pain.ability_type = Ability.AbilityType.PIERCING
    abyssal_pain.animation_type = Ability.AnimationType.ABYSSAL_SURGE
    _add_ability(abyssal_pain)

    var tornado := Ability.new()
    tornado.shield_damage = 50
    tornado.armor_damage = 50
    tornado.health_damage = 50
    tornado.name = "Fury Tornado"
    tornado.description = "You cast a massive tornado. It destroys everything in its path."
    tornado.icon = preload("uid://b0knc0runeucs")
    tornado.cooldown = 5
    tornado.ability_type = Ability.AbilityType.PIERCING
    tornado.animation_type = Ability.AnimationType.TORNADO
    _add_ability(tornado)

    var electric_torpedo := Ability.new()
    electric_torpedo.shield_damage = 175
    electric_torpedo.armor_damage = 100
    electric_torpedo.health_damage = 0
    electric_torpedo.name = "Electric Torpedo"
    electric_torpedo.description = "You channel your energy through the ground, it travels underground towards your enemy blasting them with a large electrical bolt."
    electric_torpedo.icon = preload("uid://4on43jh0nvcq")
    electric_torpedo.cooldown = 6
    electric_torpedo.ability_type = Ability.AbilityType.PIERCING
    electric_torpedo.animation_type = Ability.AnimationType.ELECTRIC_TORPEDO
    _add_ability(electric_torpedo)

func calculate_game_stage_for_turn(turn: int) -> int:
    if turn == GameState.max_turns:
        return 4
    elif turn == GameState.max_turns + 1:
        return 5
    else:
        var threshold = int(float(GameState.max_turns - 1) / 3)
        return max(ceil(float(turn) / threshold) , 1)
