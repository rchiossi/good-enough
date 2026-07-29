class_name MapLine2D extends Line2D

func add(start: Vector2, end: Vector2):
    #add_point(start)
    #add_point(end)
    create_map_path(start, end)
    default_color = Color(0.286, 0.0, 0.039, 1.0)


func create_map_path(start_pos: Vector2, end_pos: Vector2) -> void:
    var curve: Curve2D = Curve2D.new()
    curve.bake_interval = 4.0

    var mid_x_distance: float = (end_pos.x - start_pos.x) * 0.5

    var start_out_handle: Vector2 = Vector2(mid_x_distance, 0) 
    var end_in_handle: Vector2 = Vector2(-mid_x_distance, 0)

    curve.add_point(start_pos, Vector2.ZERO, start_out_handle)
    curve.add_point(end_pos, end_in_handle, Vector2.ZERO)

    self.points = curve.get_baked_points() 
    var path_length: float = curve.get_baked_length()
    var calculated_dots: float = path_length / 30.0 
    if material is ShaderMaterial:
        material.set_shader_parameter("density", calculated_dots)
