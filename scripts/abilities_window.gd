extends Control
@onready var title_label: Label = $TitleLabel
@onready var name_label: Label = $AbilityDetails/NameLabel
@onready var description_text: RichTextLabel = $AbilityDetails/DescriptionText

@onready var shield_damage_label: Label = $AbilityDetails/ShieldDamageContainer/ShieldDamageLabel
@onready var armor_damage_label: Label = $AbilityDetails/ArmorDamageContainer/ArmorDamageLabel
@onready var health_damage_label: Label = $AbilityDetails/HealthDamageContainer/HealthDamageLabel

@onready var abilities_list: HBoxContainer = $AbilitiesList
const ICON_SIZE := 128

var selected_ability: Ability = null

func _ready() -> void:
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    var empty := StyleBoxEmpty.new()

    for ability in GameState.player_abilities.values():
        var button := Button.new()
        button.icon = ability.Icon
        button.expand_icon = true
        button.add_theme_constant_override("icon_max_width", ICON_SIZE)
        button.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)

        var animation = AnimationScaleTwitch.new()
        button.add_child(animation)

        for state in ["normal", "hover", "pressed", "focus", "disabled"]:
            button.add_theme_stylebox_override(state, empty)

        button.mouse_entered.connect(func(): button.modulate = Color(1.2, 1.2, 1.2))
        button.mouse_exited.connect(func(): button.modulate = Color.WHITE)

        button.pressed.connect(_on_ability_button_pressed.bind(ability))
        abilities_list.add_child(button)
    print("ready on ", self, " label=", shield_damage_label)

func _on_ability_button_pressed(ability: Ability) -> void:
    name_label.text = ability.Name
    description_text.text = ability.Description
    shield_damage_label.text = str(ability.ShieldDamage)
    armor_damage_label.text = str(ability.ArmorDamage)
    health_damage_label.text = str(ability.HealthDamage)
    selected_ability = ability
