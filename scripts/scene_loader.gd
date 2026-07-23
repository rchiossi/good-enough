extends Node

var _loading_scene : PackedScene = preload("res://scenes/loading_screen.tscn")
var _loading_screen : LoadingScreen

var _target : String
var _progress : Array[float]
var _last_progress : float = 0.0

const use_threads : bool = false

signal loading_progress_update(progress : float)
signal loading_complete

func _ready() -> void:
    set_process(false)

func load_scene(scene: String):
    print("Loading Scene: " + scene)

    _target = scene

    _loading_screen = _loading_scene.instantiate()
    add_child(_loading_screen)
    
    _loading_screen.transition_complete.connect(_load_target)
    loading_complete.connect(_loading_screen.fade_out)

    _loading_screen.fade_in()

func _load_target():
    ResourceLoader.load_threaded_request(_target, "PackedScene", use_threads)
    set_process(true)

func _process(_delta: float) -> void:
    var status : int = ResourceLoader.load_threaded_get_status(_target, _progress)

    match status:
        ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            set_process(false)
            push_error("Loading invalid Resource: " + _target)
            print_rich("[color=RED] Loading invalid Resource: " + _target + "[/color]")
            get_tree().quit()
        ResourceLoader.THREAD_LOAD_FAILED:
            set_process(false)
            push_error("Error loading Resource: " + _target)
            print_rich("[color=RED] Error loading Resource: " + _target + "[/color]")
            get_tree().quit()
        ResourceLoader.THREAD_LOAD_IN_PROGRESS:
            if _progress[0] != _last_progress:
                _last_progress = _progress[0]
                loading_progress_update.emit(_last_progress)
        ResourceLoader.THREAD_LOAD_LOADED:
            set_process(false)
            var new_scene : PackedScene = ResourceLoader.load_threaded_get(_target)
            get_tree().change_scene_to_packed(new_scene)
            loading_complete.emit()




            
            

        

        
