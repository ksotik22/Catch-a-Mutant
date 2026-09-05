extends Node

func _ready() -> void:
    call_deferred("apply_style")

func apply_style() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    var root := get_tree().current_scene
    if root == null:
        return

    # Remove every older shop Label3D so duplicated text cannot overlap.
    for node in root.get_children():
        if node is Label3D and (node.text.contains("МАГАЗИН") or node.text.contains("УЛУЧШ") or node.text.contains("ПРОДАЖ")):
            node.queue_free()

    await get_tree().process_frame
    _make_shop_label(root, "ПРОДАЖА", Vector3(-7, 4.25, 2.15), Color("fff1c7"))
    _make_shop_label(root, "УЛУЧШЕНИЯ", Vector3(7, 4.25, 2.15), Color("d9f4ff"))

func _make_shop_label(root: Node, text_: String, pos: Vector3, color_: Color) -> void:
    var label := Label3D.new()
    label.text = text_
    label.position = pos
    label.font_size = 22
    label.modulate = color_
    label.outline_modulate = Color("15191e")
    label.outline_size = 4
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.no_depth_test = false
    label.fixed_size = false
    label.pixel_size = 0.0040
    root.add_child(label)
