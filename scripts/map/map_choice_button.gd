class_name MapChoiceButton extends CheckBox

var node_type: GameState.NodeTypes

var types_definitions: Dictionary[GameState.NodeTypes, Dictionary] = {
    GameState.NodeTypes.Start: {
        "icon": preload("uid://mwgfvnpw5xme"),
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

func set_type(n_type: GameState.NodeTypes):
    node_type = n_type
    icon = types_definitions[node_type]["icon"]

func on_pressed():
    SceneLoader.load_scene(types_definitions[node_type]["scene"])
