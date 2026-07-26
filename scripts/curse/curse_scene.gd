extends MarginContainer

var ability_scene : PackedScene = preload("uid://bdhkv4bcpgrhy")

@onready var _ability_grid : GridContainer = %AbilityGrid
@onready var _selection_grid : GridContainer = %SelectionGrid
@onready var _tooltip : CombatAbilityTooltip = %Tooltip
@onready var _confirmation_tooltip : CombatAbilityTooltip = %ConfirmationTooltip
@onready var _confirmation_dialog : MarginContainer = %ConfirmationDialog
@onready var _confirm_button : Button = %ConfirmButton
@onready var _cancel_button : Button = %CancelButton
@onready var _skip_button : Button = %SkipButton

var _selectable_abilities : Array[Ability]

var _selected : String

func _ready() -> void:
    _load_abilities_to_grid()
    _load_options()

    _confirm_button.pressed.connect(_on_confirm)
    _cancel_button.pressed.connect(_on_cancel)

func _load_abilities_to_grid():
    var player = GameState.player_stats

    for ability in player.abilities.values():
        var new_ability : CombatAbilityScene = ability_scene.instantiate()

        if not ability.is_disabled and ability.name != "Punch":
            _selectable_abilities.append(ability)
        else:
            pass #Show locked status

        _ability_grid.add_child(new_ability)
        new_ability.set_ability(ability.name)
        new_ability.set_click_disabled(true)
        new_ability.ability_hover.connect(_on_hover)

    # Debug -----
    _skip_button.pressed.connect(_on_skip)


func _load_options():
    var options : Array[Ability] = []

    _selectable_abilities.shuffle()
    while len(options) < 3 and len(_selectable_abilities) > 0:
        options.append(_selectable_abilities.pop_back())

    _tooltip.set_ability(options[0].name)

    for option in options:
        var new_ability : CombatAbilityScene = ability_scene.instantiate()
        _selection_grid.add_child(new_ability)
        new_ability.set_ability(option.name, false)
        new_ability.ability_hover.connect(_on_hover)
        new_ability.ability_activated.connect(_on_ability_selected)

func _on_hover(ability_name: String):
    _tooltip.set_ability(ability_name)

func _on_ability_selected(ability_name: String):
    _selected = ability_name
    _confirmation_tooltip.set_ability(ability_name)

    _dialog_fade_in()

func _dialog_fade_in():
    _confirmation_dialog.modulate.a = 0.0

    _confirmation_dialog.show()

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_confirmation_dialog, "modulate:a", 1.0, 0.1)

func _dialog_fade_out():
    _confirmation_dialog.show()

    var tween = create_tween()

    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.tween_property(_confirmation_dialog, "modulate:a", 0.0, 0.1)

    tween.tween_callback(_confirmation_dialog.hide)

func _on_cancel():
    _dialog_fade_out()

func _on_confirm():
    if not _selected:
        _dialog_fade_out()

    GameState.player_stats.abilities[_selected].is_disabled = true
    SceneLoader.load_scene("res://scenes/map/map.tscn")

func _on_skip():
    SceneLoader.load_scene("res://scenes/map/map.tscn")
