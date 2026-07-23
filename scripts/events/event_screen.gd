extends Control
@onready var event_text: RichTextLabel = $EventText
@onready var accept_button: Button = $ButtonContainer/AcceptButton
@onready var reject_button: Button = $ButtonContainer/RejectButton

var available_events: Array[GameEvent] = []

func _get_removeable_ability_name():
    var has_removeable_ability: bool = false
    for ability in GameState.player_stats.abilities.values():
        if ability.ability_type != Ability.AbilityType.NORMAL and not ability.is_disabled:
            has_removeable_ability = true
            break

    if not has_removeable_ability:
        return null

    var index_to_remove = randi_range(0, len(GameState.player_stats.abilities.values())-1)

    while true:
        var found_ability: Ability = GameState.player_stats.abilities.values()[index_to_remove]
        if found_ability.ability_type != Ability.AbilityType.NORMAL and not found_ability.is_disabled:
            return found_ability.name
        index_to_remove += 1
        if index_to_remove == len(GameState.player_stats.abilities):
            index_to_remove = 0
    return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reject_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var ability_to_remove: String = _get_removeable_ability_name()
    #event1
    if ability_to_remove:
        var existential_event: GameEvent = GameEvent.new()
        existential_event.text = "
            You eat a strange mushroom.
            Moments later you're wondering whether your 
            enemies are merely projections of your own
            subconscious.

            You gain + 25 health but can't ever cast " + ability_to_remove + "."
        existential_event.accept_text = "Accept enlightment"
        existential_event.reject_text = "Purge"
        existential_event.take_action_func = Callable(existential_event_callback.bind(ability_to_remove))
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
    unionized_event.take_action_func = Callable(unionized_event_callback.bind(ability_to_remove))
    available_events.append(unionized_event)
    
    #event3
    var helpmove_event: GameEvent = GameEvent.new()
    helpmove_event.text = "
        You meet an old lady who's trying to move her couch into a treehouse. 
        
        Help move the old lady and receive +25 on your magic shield."
    helpmove_event.accept_text = "Move the couch"
    helpmove_event.reject_text = "I don't have time"
    helpmove_event.take_action_func = Callable(helpmove_event_callback.bind(ability_to_remove))
    available_events.append(helpmove_event)
    
    #event4
    var tax_event: GameEvent = GameEvent.new()
    tax_event.text = "
        The royal tax collector approaches.
        The count requires a tax on.. existing
        
        Pay the tax, but you can't afford a meal for a week (-20 Health) 
        or Refuse to pay and fight the tax collector. You lose 1 ability.
    "
    tax_event.accept_text = "Pay the tax"
    tax_event.reject_text = "Refuse to pay"
    tax_event.take_action_func = Callable(tax_event_callback)
    available_events.append(tax_event)
    
    #event5
    var wildgoose_event: GameEvent = GameEvent.new()
    wildgoose_event.text = "
        A wild mega goose blocks the road. 
        He's an agressive boy and looks very confident. 
        
        Fight the wild goose and damage your armor (-15 Armor)
        Give it bread, you coward. You lose 1 ability.
    "
    wildgoose_event.accept_text = "You won. Barely.. "
    wildgoose_event.reject_text = "The goose considers you beneath violence"
    wildgoose_event.take_action_func = Callable(wildgoose_event_callback)
    available_events.append(wildgoose_event)
   
    
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
    if ability_to_toss != null:
        GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_health += 25
    GameState.player_stats.health += 25
    SceneLoader.load_scene("res://scenes/map/map.tscn")

#event2callback
func unionized_event_callback(ability_to_toss: String):
    if ability_to_toss != null:
        GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_armor += 15
    GameState.player_stats.armor += 15
    SceneLoader.load_scene("res://scenes/map/map.tscn")

#event3callback
func helpmove_event_callback(ability_to_toss: String):
    if ability_to_toss != null:
        GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_shield += 25
    GameState.player_stats.shield += 25
    SceneLoader.load_scene("res://scenes/map/map.tscn")
    
#event4callback
func tax_event_callback():
    GameState.player_stats.max_health = max(GameState.player_stats.max_health - 20, 1)
    GameState.player_stats.health = max(GameState.player_stats.health - 20, 1)
    SceneLoader.load_scene("res://scenes/map/map.tscn")    
 
#event5callback   
func wildgoose_event_callback():
    GameState.player_stats.max_armor = max(GameState.player_stats.max_armor - 15, 1)
    GameState.player_stats.armor = max(GameState.player_stats.armor - 15, 1)
    SceneLoader.load_scene("res://scenes/map/map.tscn")  

func _on_reject_button_pressed() -> void:
    SceneLoader.load_scene("res://scenes/abilities_window.tscn")
