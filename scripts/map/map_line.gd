class_name MapLine2D extends Line2D

func add(start: Vector2, end: Vector2):
    add_point(start)
    add_point(end)
    default_color = Color(0.286, 0.0, 0.039, 1.0)
    var angle = start.angle_to_point(end)
    %ArrowHead.rotation_degrees = rad_to_deg(angle)
    %ArrowHead.position = get_point_position(1) - Vector2(16, 16)
