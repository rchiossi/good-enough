extends Control
@onready var title_label: Label = $TitleLabel
@onready var name_label: Label = $AbilityDetails/NameLabel
@onready var description_text: RichTextLabel = $AbilityDetails/DescriptionText

@onready var shield_damage_label: Label = $AbilityDetails/ShieldDamageContainer/ShieldDamageLabel
@onready var armor_damage_label: Label = $AbilityDetails/ArmorDamageContainer/ArmorDamageLabel
@onready var health_damage_label: Label = $AbilityDetails/HealthDamageContainer/HealthDamageLabel
@onready var cooldown_label: Label = $AbilityDetails/CooldownContainer/CooldownLabel
@onready var confirmation_dialog: SimpleDialog = $ConfirmationDialog
@onready var hover_sound_1: AudioStreamPlayer2D = $HoverSound1
@onready var hover_bad_sound: AudioStreamPlayer2D = $HoverBadSound
@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var click_bad_sound: AudioStreamPlayer2D = $ClickBadSound

@onready var abilities_list: HBoxContainer = $AbilitiesList
const ICON_SIZE := 128

var selected_ability: Ability = null

func _ready() -> void:
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var empty := StyleBoxEmpty.new()
    confirmation_dialog.confirmed.connect(_on_forget_button_pressed)

    for ability in GameState.player_stats.abilities.values():
        var button := Button.new()
        button.icon = ability.icon
        button.expand_icon = true
        button.add_theme_constant_override("icon_max_width", ICON_SIZE)
        button.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
        if ability.is_disabled:
            button.self_modulate = Color(0.35, 0.35, 0.35)

        var animation = AnimationScaleTwitch.new()
        button.add_child(animation)

        for state in ["normal", "hover", "pressed", "focus", "disabled"]:
            button.add_theme_stylebox_override(state, empty)

        button.mouse_entered.connect(_on_ability_button_hovered.bind(ability))

        button.pressed.connect(_on_ability_button_pressed.bind(ability))
        abilities_list.add_child(button)
    print("ready on ", self, " label=", shield_damage_label)

func _on_ability_button_hovered(ability: Ability) -> void:
    if ability.is_disabled:
        hover_bad_sound.play()
        return
    name_label.text = ability.name
    description_text.text = ability.description
    shield_damage_label.text = str(ability.shield_damage)
    armor_damage_label.text = str(ability.armor_damage)
    health_damage_label.text = str(ability.health_damage)
    cooldown_label.text = str(ability.cooldown) + " turns"
    selected_ability = ability
    hover_sound_1.play()

func _on_ability_button_pressed(ability: Ability) -> void:
    if ability.is_disabled:
        click_bad_sound.play()
        return
    selected_ability = ability
    confirmation_dialog.dialog_text_label.text = "Forget " + ability.name + "?"
    confirmation_dialog.confirm_button.text = "Forget"
    confirmation_dialog.cancel_button.text = "KEEP"
    confirmation_dialog.fade_in()
    click_sound.play()

func _on_forget_button_pressed() -> void:
    if not selected_ability:
        return
    GameState.player_stats.abilities[selected_ability.name].is_disabled = true
    SceneLoader.load_scene("res://scenes/map/map.tscn")
