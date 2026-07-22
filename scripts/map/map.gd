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
    var map = {}
    map[0] = [GameState.NodeTypes.Start]
    for i in range(1, GameState.max_turns):
        var nr_nodes = randi() % 4 + 1
        map[i] = []
        for j in range(nr_nodes):
            map[i].append(GameState.NodeTypes.values()[randi_range(1, 2)])
    map[GameState.max_turns] = [GameState.NodeTypes.Count]
    GameState.map = map
