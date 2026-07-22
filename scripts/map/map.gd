extends Control

var level_scene: PackedScene = preload("uid://00urot6twxdg")


func _ready() -> void:
    generate_map()
    for i in range(GameState.max_turns):
        var level = MapLevelScene.new(i)
        %MapNodesContainer.add_child(level)
        var separator = VSeparator.new()
        separator.custom_minimum_size.x = 128
        %MapNodesContainer.add_child(separator)
    %MapNodesContainer.add_child(MapLevelScene.new(GameState.max_turns))


func generate_map():
    if GameState.map:
        return
    var rng = RandomNumberGenerator.new()
    var possible_nodes = [GameState.NodeTypes.Null, GameState.NodeTypes.Fight, GameState.NodeTypes.Event]
    var weights = PackedFloat32Array([1, 1, 0.5])
    var map = {}
    map[0] = {
        "nodes": {
            0: {
                "type": GameState.NodeTypes.Start
            }
        },
        "status": 0,
    }
    for i in range(1, GameState.max_turns):
        map[i] = {
            "nodes": {},
            "status": 1,
        }
        var at_least_one_node = false
        for j in range(4):
            var type =  possible_nodes[rng.rand_weighted(weights)]
            if type != GameState.NodeTypes.Null:
                at_least_one_node = true
            map[i]["nodes"][j] = {
                "type": type,
            }
        if not at_least_one_node:
            map[i]["nodes"][randi_range(0, 3)] = {
                "type": GameState.NodeTypes.values()[randi_range(1, 2)],
            }
        
    map[GameState.max_turns] = {
        "nodes": {
            0: {
                "type": GameState.NodeTypes.Count,
            }
        },
        "status": 1,
    }
    GameState.map = map
