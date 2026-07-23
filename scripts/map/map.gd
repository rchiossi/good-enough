extends Control

var level_scene: PackedScene = preload("uid://00urot6twxdg")

var max_nodes = 4

func _ready() -> void:
    generate_map()
    _generate_paths()
    for i in range(GameState.max_turns):
        var level = MapLevelScene.new(i)
        %MapNodesContainer.add_child(level)
        var separator = VSeparator.new()
        separator.custom_minimum_size.x = 128
        %MapNodesContainer.add_child(separator)
    %MapNodesContainer.add_child(MapLevelScene.new(GameState.max_turns))
    for n in GameState.connections[GameState.current_position]["children"]:
        GameState.nodes[n].disabled = false
        

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
        for j in range(max_nodes):
            var type =  possible_nodes[rng.rand_weighted(weights)]
            if type != GameState.NodeTypes.Null:
                at_least_one_node = true
            map[i]["nodes"][j] = {
                "type": type,
            }
        if not at_least_one_node:
            map[i]["nodes"][randi_range(0, 3)] = {
                "type": GameState.NodeTypes.values()[randi_range(2, 3)],
            }
        
    map[GameState.max_turns] = {
        "nodes": {
            0: {
                "type": GameState.NodeTypes.Null,
            },
            1: {
                "type": GameState.NodeTypes.Null,
            },
            2: {
                "type": GameState.NodeTypes.Count,
            },
            3: {
                "type": GameState.NodeTypes.Null,
            },
        },
        "status": 1,
    }
    GameState.map = map
    GameState.current_position = Vector2i(0, 0)
    _generate_paths()

func _generate_paths():
    if GameState.connections:
        return
    for i in range(GameState.max_turns):
        var nr_nodes = _get_nr_of_nodes(i)

        for j in GameState.map[i]["nodes"]:
            if GameState.map[i]["nodes"][j]["type"] == GameState.NodeTypes.Null:
                continue
            var neighbours = _get_next_neighbours(Vector2i(i, j))
            GameState.connections[Vector2i(i, j)] = {"children": []}
            if nr_nodes == 1 or not neighbours:
                # TODO: for the case when there are no neighbours we should go to the closes node
                # As a temporary fix I allow any node
                for n in range(max_nodes):
                    if GameState.map[i + 1]["nodes"][n]["type"] != GameState.NodeTypes.Null:
                        GameState.connections[Vector2i(i, j)]["children"].append(Vector2i(i+1, n))
                continue

            for r in range(randi_range(1, 3)):
                var n = neighbours[randi() % neighbours.size()]
                neighbours.erase(n)
                GameState.connections[Vector2i(i, j)]["children"].append(n)
                if not neighbours:
                    break

func _get_nr_of_nodes(level: int) -> int:
    var result: int = 0
    for n in GameState.map[level]["nodes"].values():
        if n["type"] != GameState.NodeTypes.Null:
            result += 1
    return result

func _get_next_neighbours(coords: Vector2i) -> Array[Vector2i]:
    var neighbours: Array[Vector2i] = []
    for j in range(coords.y - 1, coords.y + 1):
        if j < 0 :
            continue
        if j > 3:
            continue
        if GameState.map[coords.x + 1]["nodes"][j]["type"] != GameState.NodeTypes.Null:
            neighbours.append(Vector2i(coords.x + 1, j))
    return neighbours
