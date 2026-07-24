class_name MapChoiceButton extends CheckBox

var node_type: GameState.NodeTypes

var coords: Vector2i

var types_definitions: Dictionary[GameState.NodeTypes, Dictionary] = {
    GameState.NodeTypes.Start: {
        "icon": preload("uid://drwkrq24ebc0n"),
        "scene": "uid://c7f7ypqju21gh",
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
        "scene": "uid://8m56dhcqa170",
    },
    GameState.NodeTypes.Count: {
        "icon": preload("uid://drev3okyfa374"),
        "scene": "uid://csqef5bpcx1cc",
    },
}

var color_enabled: Color = Color("#5bb362")
var color_disabled: Color = Color("#b34947")
var color_highlight: Color = Color("#5275a3")

func _ready() -> void:
    pass

func set_coords(c: Vector2i):
    coords = c
    node_type = GameState.map[coords.x]["nodes"][coords.y]["type"]
    icon = types_definitions[node_type]["icon"]
    tooltip_text = GameState.NodeTypes.keys()[node_type]
    if GameState.map[coords.x]["nodes"][coords.y].get("visited") == 1:
        %DoneHighlight.visible = true
    if coords.x == GameState.max_turns:
        material.set("shader_parameter/Width", 0)
    material.set("shader_parameter/ColorParameter", color_disabled)

func on_pressed():
    SceneLoader.load_scene(types_definitions[node_type]["scene"])

func show_highlight():
    if disabled:
        material.set("shader_parameter/ColorParameter", color_highlight)
    
func hide_highlight():
    if disabled:
        material.set("shader_parameter/ColorParameter", color_disabled)
    else:
        material.set("shader_parameter/ColorParameter", color_enabled)
        

func enable_button():
    disabled = false
    if coords.x == GameState.max_turns:
        material.set("shader_parameter/Width", 0)
    else:
        material.set("shader_parameter/ColorParameter", color_enabled)

func _on_mouse_entered() -> void:
    show_highlight()
    for n in GameState.connections.get(coords, {}).get("children", []):
        GameState.nodes[n].show_highlight()

func _on_mouse_exited() -> void:
    hide_highlight()
    for n in GameState.connections.get(coords, {}).get("children", []):
        GameState.nodes[n].hide_highlight()
