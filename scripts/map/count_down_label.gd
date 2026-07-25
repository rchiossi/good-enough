class_name CountdownLabel extends RichTextLabel

var textures = {
    1: preload("uid://q1ai2p3kgxt7"),
    2: preload("uid://bp4ntlwj5nqc1"),
    3: preload("uid://bcqndd1lorvsf"),
    4: preload("uid://clbwkwgl87jnm"),
}

func set_level(countdown: int):
    if countdown == GameState.max_turns:
        text = "Count"
    else:
        text = "%s" %  (GameState.max_turns - countdown)
    var gstage = GameState.calculate_game_stage_for_turn(countdown)
    %CountdownTexture.texture = textures.get(gstage, preload("uid://q1ai2p3kgxt7"))
