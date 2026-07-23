class_name MapChoiceButton extends CheckBox

var node_type: GameState.NodeTypes

var coords: Vector2i

var types_definitions: Dictionary[GameState.NodeTypes, Dictionary] = {
    GameState.NodeTypes.Start: {
        "icon": preload("uid://mwgfvnpw5xme"),
        "scene": null,
    },
    GameState.NodeTypes.Null: {
        "icon": null,
        "scene": null,
    },
    GameState.NodeTypes.Fight: {
        "icon": preload("uid://c7j2jmc6jv7cv"),
        "scene": "uid://csqef5bpcx1cc",
    },
    GameState.NodeTypes.Event: {
        "icon": preload("uid://2xwi22qnlxkx"),
        "scene": "uid://bdphiv180ieyo",
    },
    GameState.NodeTypes.Count: {
        "icon": preload("uid://ck4832tptslp2"),
        "scene": "uid://csqef5bpcx1cc",
    },
}

func _ready() -> void:
    pass

func set_coords(c: Vector2i):
    coords = c
    node_type = GameState.map[coords.x]["nodes"][coords.y]["type"]
    icon = types_definitions[node_type]["icon"]
    #if GameState.current_position.x != coords.x - 1:
        #disabled = true
    #if GameState.map[coords.x]["status"] == 0:
        #disabled = true
    if GameState.map[coords.x]["nodes"][coords.y].get("visited") == 1:
        %DoneHighlight.visible = true

func on_pressed():
    SceneLoader.load_scene(types_definitions[node_type]["scene"])
    #get_tree().change_scene_to_file(types_definitions[node_type]["scene"])

func show_highlight():
    %HoverHighlight.visible = true
    
func hide_highlight():
    %HoverHighlight.visible = false

func _on_mouse_entered() -> void:
    show_highlight()
    for n in GameState.connections.get(coords, []).get("children", []):
        GameState.nodes[n].show_highlight()

func _on_mouse_exited() -> void:
    #if not get_rect().has_point(get_local_mouse_position()):
    hide_highlight()
    for n in GameState.connections[coords].get("children", []):
        GameState.nodes[n].hide_highlight()
