extends Control

var possible_nodes = [GameState.NodeTypes.Null, GameState.NodeTypes.Fight, GameState.NodeTypes.Event]
@export var weights = PackedFloat32Array([0.75, 1, 0.25])

var level_scene: PackedScene = preload("uid://00urot6twxdg")
var line_scene: PackedScene = preload("res://scenes/map/map_line.tscn")
var header_scene: PackedScene = preload("uid://bsfv6cyo6e14t")

var max_nodes = 4
var show_line = false

func _ready() -> void:
    generate_map()
    _generate_paths()
    for i in range(GameState.max_turns):
        add_node(i)
        add_countdown_label(i)

    # add Count
    add_node(GameState.max_turns)
    add_countdown_label(GameState.max_turns)
    await get_tree().process_frame

    # enable initial nodes
    for n in GameState.connections[GameState.current_position]["children"]:
        GameState.nodes[n].enable_button()
    if GameState.current_position == Vector2i(-1, -1):
        GameState.nodes[Vector2i(0, 0)].enable_button()
    else:
        %PlayerSprite2D.visible = true
        await get_tree().process_frame
        var next = GameState.nodes[GameState.connections[GameState.current_position]["children"][0]]
        if GameState.current_position.x > 2:
            %ScrollContainer.ensure_control_visible(next)
            if GameState.current_position.x > 5:
                %ScrollContainer.scroll_horizontal += 180
            else:
                %ScrollContainer.scroll_horizontal += 60
    show_line = true
    if GameState.DEBUG:
        $MarginContainer.visible = true
        %Day.placeholder_text = str(GameState.current_position.x)
        %Node.placeholder_text = str(GameState.current_position.y)
    else:
        $MarginContainer.visible = false
        
    %PlayerSprite2D.offset_transform_enabled = true
    animate_idle()
    %MapCanvas.custom_minimum_size = %MapNodesContainer.size
    await get_tree().process_frame
    show_paths()
    var current_node: MapChoiceButton = GameState.nodes.get(GameState.current_position)
    if not current_node:
        return
    %PlayerSprite2D.global_position = Vector2(
        current_node.global_position.x +  2 * current_node.size.x / 3,
        current_node.global_position.y
    )

func show_paths():
    for n in GameState.nodes.keys():
        var current = GameState.nodes[n]
        for c in GameState.connections.get(n, {}).get("children", []):
            var next = GameState.nodes[c]
            var start = current.global_position + current.size / 2
            var end = next.global_position + next.size / 2
            var line = line_scene.instantiate()
            line.add(start, end)
            if current.visited and next.visited:
                line.default_color = GameState.color_visited
            %MapCanvas.add_child(line)

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
    if GameState.DEBUG and event.is_action_pressed("show_paths"):
        GameState.map = {}
        GameState.connections = {}
        get_tree().reload_current_scene()

func add_countdown_label(countdown: int):
    var header_label: CountdownLabel = header_scene.instantiate()
    header_label.set_level(countdown)
    %HeaderContainer.add_child(header_label)

func add_node(countdown: int):
    var level = level_scene.instantiate()
    level.level_id = countdown
    %MapNodesContainer.add_child(level)

func generate_map():
    if GameState.map:
        return
    var rng = RandomNumberGenerator.new()
    var map = {
        0: {
            "nodes": {
                0: {
                    "type": GameState.NodeTypes.Start,
                    "visited": 1,
                }
            },
            "status": 0,
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
    GameState.current_position = Vector2i(0, 0)
    GameState.current_turn = -1
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
            if nr_nodes == 1:
                for n in range(max_nodes):
                    if GameState.map[i + 1]["nodes"][n]["type"] != GameState.NodeTypes.Null:
                        GameState.connections[Vector2i(i, j)]["children"].append(Vector2i(i+1, n))
                continue
            if not neighbours:
                var closest_node = null
                for node in  GameState.map[i + 1]["nodes"]:
                    if GameState.map[i + 1]["nodes"][node]["type"] != GameState.NodeTypes.Null:
                        if not closest_node:
                            closest_node = Vector2i(i + 1, node)
                        else:
                            if abs(node - j) < abs(closest_node.y - j):
                                closest_node = Vector2i(i + 1, node)
                GameState.connections[Vector2i(i, j)]["children"].append(_get_closest_next(Vector2i(i, j)))
                continue
    
            for r in range(randi_range(1, 2)):
                var n = neighbours[randi() % neighbours.size()]
                neighbours.erase(n)
                GameState.connections[Vector2i(i, j)]["children"].append(n)
                if not neighbours:
                    break
    
    _sanity_check_paths()

func _get_nr_of_nodes(level: int) -> int:
    var result: int = 0
    for n in GameState.map[level]["nodes"].values():
        if n["type"] != GameState.NodeTypes.Null:
            result += 1
    return result

func _get_next_neighbours(coords: Vector2i) -> Array[Vector2i]:
    var neighbours: Array[Vector2i] = []
    for j in range(coords.y - 1, coords.y + 2):
        if j < 0 :
            continue
        if j > 3:
            continue
        if GameState.map[coords.x + 1]["nodes"][j]["type"] != GameState.NodeTypes.Null:
            neighbours.append(Vector2i(coords.x + 1, j))
    return neighbours

func _sanity_check_paths():
    for i in GameState.map:
        for j in GameState.map[i]["nodes"]:
            if Vector2i(i + 1, j + 1) in GameState.connections.get(Vector2i(i, j), {}).get("children", {}):
                if Vector2i(i + 1, j) in GameState.connections.get(Vector2i(i, j + 1), {}).get("children", {}):
                    GameState.connections[Vector2i(i, j)]["children"].erase(Vector2i(i + 1, j + 1))
    for i in GameState.map:
        for j in GameState.map[i]["nodes"]:
            if GameState.map[i]["nodes"][j]["type"] == GameState.NodeTypes.Null:
                continue
            if i == 0:
                continue
            if not GameState.connections.get(Vector2i(i, j), {}).get("children", {}) and i != GameState.max_turns:
                GameState.connections[Vector2i(i, j)]["children"] = [_get_closest_next(Vector2i(i, j))]
            var ok = false
            for k in GameState.map[i - 1]["nodes"]:
                if  GameState.map[i - 1]["nodes"][k]["type"] == GameState.NodeTypes.Null:
                    continue
                if Vector2i(i, j) in GameState.connections.get(Vector2i(i -1, k), {}).get("children", {}):
                    ok = true
                    break
            if not ok:
                GameState.connections[_get_closest_previous(Vector2i(i, j))]["children"].append(Vector2i(i, j))

func _get_closest(current: Vector2i, direction: int = 1) -> Vector2i:
    var closest_node = Vector2i(-1, -1)
    var x = current.x + direction * 1
    for node in  GameState.map[x]["nodes"]:
        if GameState.map[x]["nodes"][node]["type"] != GameState.NodeTypes.Null:
            if closest_node.x < 0:
                closest_node = Vector2i(x, node)
            else:
                if abs(node - current.y) < abs(closest_node.y - current.y):
                    closest_node = Vector2i(x, node)
    return closest_node

func _get_closest_previous(current: Vector2i) -> Vector2i:
    return _get_closest(current, -1)

func _get_closest_next(current: Vector2i) -> Vector2i:
    return _get_closest(current, 1)

func _on_skip_button_pressed() -> void:
    var x = int(%Day.text)
    var y = int(%Node.text)
    goto(Vector2i(x, y))

func goto(node: Vector2i) -> void:
    if not GameState.nodes.get(node) or GameState.nodes[node].node_type == GameState.NodeTypes.Null:
        return
    GameState.current_position = node
    GameState.current_turn = GameState.current_position.x
    GameState.map[GameState.current_position.x]["status"]  = 0
    GameState.map[GameState.current_position.x]["nodes"][GameState.current_position.y]["visited"] = 1
    SceneLoader.load_scene("res://scenes/map/map.tscn")

func animate_idle():
    var tween = create_tween()

    tween.set_loops()

    tween.tween_interval(randf() * 3.0)
    tween.tween_property(%PlayerSprite2D, "offset_transform_position", Vector2(10, -5), 0.5)
    tween.tween_property(%PlayerSprite2D, "offset_transform_position", Vector2(20, 0), 0.5)
    tween.tween_interval(randf() * 3.0)
    tween.tween_property(%PlayerSprite2D, "offset_transform_position", Vector2(10, -5), 0.5)
    tween.tween_property(%PlayerSprite2D, "offset_transform_position", Vector2(0, 0), 0.5)
