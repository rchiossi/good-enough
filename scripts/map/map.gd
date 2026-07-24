extends Control

var level_scene: PackedScene = preload("uid://00urot6twxdg")

var max_nodes = 4

func _ready() -> void:
    generate_map()
    _generate_paths()
    for i in range(GameState.max_turns):
        add_node(i)
        add_countdown_label(str(GameState.max_turns - i))

    # add Count
    add_node(GameState.max_turns)
    add_countdown_label("Count")

    # enable initial nodes
    for n in GameState.connections[GameState.current_position]["children"]:
        GameState.nodes[n].disabled = false
    if GameState.current_position == Vector2i(-1, -1):
        GameState.nodes[Vector2i(0, 0)].disabled = false
    else:
        %PlayerSprite2D.visible = true

func _process(_delta: float) -> void:
    var current_node: MapChoiceButton = GameState.nodes.get(GameState.current_position)
    if not current_node:
        return
    %PlayerSprite2D.global_position = Vector2(
        current_node.global_position.x + current_node.size.x,
        current_node.global_position.y + current_node.size.y / 2
    )

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        if %HelpContainer.visible:
            %HelpContainer.visible = false
        else:
            %SettingsPanel.fade_in()
    if event.is_action_pressed("show_player_info"):
        SceneLoader.load_scene("uid://81rbkmiw7hyl")
    if event.is_action_pressed("show_help"):
        %HelpContainer.visible = not %HelpContainer.visible

func add_countdown_label(countdown: String):
    var header_label = RichTextLabel.new()
    header_label.text = "%s" % countdown
    header_label.custom_minimum_size.x = 136
    header_label.custom_maximum_size.x = 136
    header_label.custom_minimum_size.y = 64
    header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    header_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    header_label.theme_type_variation = "MapRichTextLabel"
    %HeaderContainer.add_child(header_label)
    var separator2 = VSeparator.new()
    separator2.custom_minimum_size.x = 96
    %HeaderContainer.add_child(separator2)

func add_node(countdown: int):
    var level = level_scene.instantiate()
    level.level_id = countdown
    %MapNodesContainer.add_child(level)
    var separator = VSeparator.new()
    separator.custom_minimum_size.x = 96
    %MapNodesContainer.add_child(separator)

func generate_map():
    if GameState.map:
        return
    var rng = RandomNumberGenerator.new()
    var possible_nodes = [GameState.NodeTypes.Null, GameState.NodeTypes.Fight, GameState.NodeTypes.Event]
    var weights = PackedFloat32Array([1, 1, 0.5])
    var map = {
        0: {
            "nodes": {
                0: {
                    "type": GameState.NodeTypes.Start
                }
            },
            "status": 1,
        }
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
    GameState.current_position = Vector2i(-1, -1)
    _generate_paths()

func _generate_paths():
    if GameState.connections:
        return
    GameState.connections = {
        Vector2i(-1, -1): {
            "children": []
        }
    }
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
