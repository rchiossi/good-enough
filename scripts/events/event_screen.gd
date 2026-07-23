extends Control
@onready var event_text: RichTextLabel = $EventText
@onready var accept_button: Button = $ButtonContainer/AcceptButton
@onready var reject_button: Button = $ButtonContainer/RejectButton

var available_events: Array[GameEvent] = []

func _get_removeable_ability() -> Ability:
    var has_removeable_ability: bool = false
    for ability in GameState.player_stats.abilities.values():
        if ability.ability_type != Ability.AbilityType.NORMAL:
            has_removeable_ability = true
            break

    if not has_removeable_ability:
        return null

    var index_to_remove = randi_range(0, len(GameState.player_stats.abilities.values())-1)

    while true:
        var found_ability: Ability = GameState.player_stats.abilities.values()[index_to_remove]
        if found_ability.ability_type != Ability.AbilityType.NORMAL:
            return found_ability
        index_to_remove += 1
        if index_to_remove == len(GameState.player_stats.abilities):
            index_to_remove = 0
    return null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reject_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var ability_1 = _get_removeable_ability().name
    #event1
    var existential_event: GameEvent = GameEvent.new()
    existential_event.text = "
        You eat a strange mushroom.
        Moments later you're wondering whether your 
        enemies are merely projections of your own
        subconscious.

        You gain + 25 health but can't ever cast " + ability_1 + "."
    existential_event.accept_text = "Accept enlightment"
    existential_event.reject_text = "Purge"
    existential_event.take_action_func = Callable(existential_event_callback.bind(ability_1))
    available_events.append(existential_event)
    
    #event2
    var unionized_event: GameEvent = GameEvent.new()
    unionized_event.text = "
        You stumble upon a gang of bandits picketing instead of pillaging.
        <<Fair pay for fair plunder>>
        Their leader hands you a pamphlet.

        You gain + 15 on your armor when you help unionizing the bandits"
    unionized_event.accept_text = "Unionize bandits!"
    unionized_event.reject_text = "Not my problem"
    unionized_event.take_action_func = Callable(unionized_event_callback.bind(ability_1))
    available_events.append(unionized_event)
    
    #event3
    var helpmove_event: GameEvent = GameEvent.new()
    helpmove_event.text = "
        You meet an old lady who's trying to move her couch into a treehouse. 
        
        Help move the old lady and receive +25 on your magic shield."
    helpmove_event.accept_text = "Move the couch"
    helpmove_event.reject_text = "I don't have time"
    helpmove_event.take_action_func = Callable(helpmove_event_callback.bind(ability_1))
    available_events.append(helpmove_event)
    
    
    
    choose_random_event() 

func choose_random_event():
    var event_index = randi_range(0, len(available_events)-1)
    var picked_event = available_events[event_index]
    event_text.text = picked_event.text
    accept_button.text = picked_event.accept_text
    accept_button.pressed.connect(picked_event.take_action_func)
    reject_button.text = picked_event.reject_text

#event1callback
func existential_event_callback(ability_to_toss: String):
    GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_health += 25
    GameState.player_stats.health += 25
    SceneLoader.load_scene("res://scenes/map/map.tscn")

#event2callback
func unionized_event_callback(ability_to_toss: String):
    GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_armor += 15
    GameState.player_stats.armor += 15
    SceneLoader.load_scene("res://scenes/map/map.tscn")

#event3callback
func helpmove_event_callback(ability_to_toss: String):
    GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_shield += 25
    GameState.player_stats.shield += 25
    SceneLoader.load_scene("res://scenes/map/map.tscn")

func _on_reject_button_pressed() -> void:
    SceneLoader.load_scene("res://scenes/abilities_window.tscn")
