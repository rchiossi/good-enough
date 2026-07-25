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
        return ""

    var index_to_remove = randi_range(0, len(GameState.player_stats.abilities.values())-1)

    while true:
        var found_ability: Ability = GameState.player_stats.abilities.values()[index_to_remove]
        if found_ability.ability_type != Ability.AbilityType.NORMAL and not found_ability.is_disabled:
            return found_ability.name
        index_to_remove += 1
        if index_to_remove == len(GameState.player_stats.abilities):
            index_to_remove = 0
    return ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reject_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var ability_to_remove: String = _get_removeable_ability_name()
    #event1
    if ability_to_remove:
        var existential_event: GameEvent = GameEvent.new()
        existential_event.text = "
        A strange mushroom hums with forbidden knowledge.

        The spores have already taken root.
        Whether you embrace them or fight them, a piece of your
        magic will be erased forever.

        Accepting gives you 50% chance to gain +25 health
        Unfortunately, your brain permanently forgets how to cast " + ability_to_remove + ".
            
        Reject the mushrooms gift and choose an ability to sacrife. 
        "
            
        existential_event.accept_text = "Accept enlightment"
        existential_event.accept_text += "\n[color=red](Lose [i]%s[/i])[/color]" % ability_to_remove
        existential_event.reject_text = "Purge"
        existential_event.take_action_func = Callable(existential_event_callback.bind(ability_to_remove))
        available_events.append(existential_event)
    
    #event2
    var unionized_event: GameEvent = GameEvent.new()
    unionized_event.text = "
    You stumble upon a gang of bandits holding signs instead of swords.
    
    <<Fair Pay for Fair Plunder!>>
    
    Their leader cracks his knuckles and politely shoves a petition into your hands.
    <<You are going to sign this...voluntarily>>

    Join the union and gain + 15 armor but have 75% chance to lose " + ability_to_remove + " because it gets redistributed.
    
    Refuse and bandits peacefully reposses an ability of your choosing
    " 
       
    unionized_event.accept_text = "Join the union!"
    if ability_to_remove:
        unionized_event.accept_text += "\n[color=red](Gain +15 Armor, possibly lose [i]%s[/i])[/color]" % ability_to_remove
    unionized_event.reject_text = "Hand over one ability"
    unionized_event.take_action_func = Callable(unionized_event_callback.bind(ability_to_remove))
    available_events.append(unionized_event)
    
    #event3
    var helpmove_event: GameEvent = GameEvent.new()
    helpmove_event.text = "
    You find a granny struggling to haul an oversized couch into a treehouse.

    She notices you.
    <<Oh, perfect! A strong young lad.
    This won't take but a minute.>>

    You have a feeling she's said that before..
        
    Help granny and gain +25 magic shield. 
    However, there is a 50% chance you'll have to move grannys entire house.
    Causing you to lose -25 magic armor.
    
    Reject granny and she'll take an ability of your choice to teach you to respect your elders.
    "
    helpmove_event.accept_text = "Lift with your legs"
    helpmove_event.accept_text += "\n[color=red](May gain or lose [i]25 Magic Shield[/i])[/color]"
    helpmove_event.reject_text = "Suddenly remember an appointment"
    helpmove_event.take_action_func = Callable(helpmove_event_callback)
    available_events.append(helpmove_event)
    
    #event4
    var tax_event: GameEvent = GameEvent.new()
    tax_event.text = "
    A royal tax collector blocks your path.
    He unfurls a scroll several meters long.
    <<By order of the Count, all citizens are required to pay the Royal Existence Tax.>>

    Yes, you are being taxed... for existing.

    Unfortunately, your existence has been more expensive than expected.
        
    Pay the tax, but you can't afford a meal for a week (-20 Health)  
    or hand over 1 ability.
    "
    tax_event.accept_text = "Pay the Existence Tax"
    tax_event.accept_text += "\n[color=red](Lose [i]-20 HP[/i])[/color]"
    tax_event.reject_text = "I have.. other assets"
    tax_event.take_action_func = Callable(tax_event_callback)
    available_events.append(tax_event)
    
    #event5
    var wildgoose_event: GameEvent = GameEvent.new()
    wildgoose_event.text = "
        A wild Mega Goose blocks the road. 
        He's an agressive boy and looks very confident. 
        
        Fight the wild goose and damage your armor (-15 Armor)
        
        Give the Mega Goose some bread as tribute. 
        The goose now considers itself your superior and demands
        a permanent sign of respect. Lose 1 ability
        
    "
    wildgoose_event.accept_text = "Challenge the Goose"
    wildgoose_event.accept_text += "\n[color=red](Lose [i]-15 Armor[/i])[/color]"
    wildgoose_event.reject_text = "Pay the Goose Tax"
    wildgoose_event.take_action_func = Callable(wildgoose_event_callback)
    available_events.append(wildgoose_event)
   
    #event6
    var well_event: GameEvent = GameEvent.new()
    well_event.text = "
        You come across an old wishing well. 
        Someone scribbled: 
            
        <<definitley not cursed>>
        
        Throw a coin and see what happens.. 
        
        Ignore the well and lose 1 ability.        
    "
    well_event.accept_text = "Trust the Definitely-Not-Cursed Well"
    well_event.accept_text += "\n[color=red](30% you gain [i]20 Health[/i] 70% you lose [i]20 Health[/i])[/color]"
    well_event.reject_text = "Pretend You Didn't See It"
    well_event.take_action_func = Callable(well_event_callback)
    available_events.append(well_event)

    while not choose_random_event():
        assert(len(available_events) != len(GameState.used_events))
        continue

func choose_random_event() -> bool:
    var event_index = randi_range(0, len(available_events)-1)

    if event_index in GameState.used_events:
        return false

    GameState.used_events.append(event_index)

    var picked_event = available_events[event_index]
    %FirstPageText.text = picked_event.text
    %AcceptButtonText.text = picked_event.accept_text
    accept_button.pressed.connect(picked_event.take_action_func)
    reject_button.text = picked_event.reject_text
    
    return true

#event1callback
func existential_event_callback(ability_to_toss: String):
    if ability_to_toss != null:
        GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    var healthChance = randi_range(1,2)
    if healthChance == 1:
        GameState.player_stats.max_health += 25
        GameState.player_stats.health += 25
    SceneLoader.load_scene("res://scenes/map/map.tscn")

#event2callback
func unionized_event_callback(ability_to_toss: String):
    var abilityChance = randi_range(1,4)
    if abilityChance >= 2:
        if ability_to_toss != null:
            GameState.player_stats.abilities[ability_to_toss].is_disabled = true
    GameState.player_stats.max_armor += 15
    GameState.player_stats.armor += 15
    SceneLoader.load_scene("res://scenes/map/map.tscn")

#event3callback
func helpmove_event_callback():
    var armorChance = randi_range(1,2)
    if armorChance == 1:
        GameState.player_stats.max_shield += 25
        GameState.player_stats.shield += 25
    else:
        GameState.player_stats.max_shield = max(GameState.player_stats.max_shield - 25, 1)
        GameState.player_stats.shield = max(GameState.player_stats.shield - 25, 1)
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
    
#event6callback
func well_event_callback():
    var chance = randi_range(1,10)
    if chance <= 7:
        GameState.player_stats.max_health = max(GameState.player_stats.max_health - 20, 1)
        GameState.player_stats.health = max(GameState.player_stats.max_health - 20, 1)  
    else:
        GameState.player_stats.max_health += 20
        GameState.player_stats.health += 20            
    SceneLoader.load_scene("res://scenes/map/map.tscn") 

func _on_reject_button_pressed() -> void:
    SceneLoader.load_scene("res://scenes/curse/curse_scene.tscn")
