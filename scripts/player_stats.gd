extends Control

@onready var player : EntityScene = %Player

var _player_stats : EntityStats

@onready var _player_sprite : Texture2D = preload("res://assets/combat/player.png")

@onready var _ability_grid : CombatAbilityGrid = %AbilityGrid
@onready var _ability_info : CombatAbilityTooltip = %AbilityInfo

var _ability_scene : PackedScene = preload("res://scenes/Combat/combat_ability.tscn")

var _entity_scenes : Dictionary[String, EntityScene] = {}

func _ready() -> void:
    _player_stats = GameState.player_stats
    _player_stats.init()

    player.init(_player_stats, _player_sprite )
    _entity_scenes[player.stats.name] = player

    load_abilities_to_grid()

    _ability_info.hide()

    var entities : Dictionary[String, EntityStats] = {}
    entities[_player_stats.name] = _player_stats

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") or event.is_action_pressed("show_player_info"):
        SceneLoader.load_scene("uid://bqa756pyqync2")

func load_abilities_to_grid():
    for ability in _player_stats.abilities.values():
        if ability.is_disabled:
            continue
        var scene : CombatAbilityScene = _ability_scene.instantiate()
        _ability_grid.add_item(scene)
        scene.set_ability(ability.name)
        scene.show_tooltip.connect(_show_ability_info)

func _show_ability_info(ability_name : String):
    _ability_info.set_ability(ability_name)
    _ability_info.show()
