extends Node

func _ready() -> void:
    call_deferred("apply_style")

func apply_style() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    var root := get_tree().current_scene
    if root == null:
        return
    for node in root.get_children():
        if node is Label3D and (node.text == "МАГАЗИН" or node.text == "УЛУЧШЕНИЯ" or node.text == "ПРОДАЖА"):
            node.font_size = 30
            node.modulate = Color("fff4d6")
            node.outline_modulate = Color("20242b")
            node.outline_size = 5
            node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
            node.no_depth_test = false
            node.fixed_size = false
            node.pixel_size = 0.0055
