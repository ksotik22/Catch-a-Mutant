extends CanvasLayer

@onready var catch_label: Label = $CatchLabel
@onready var game_state = get_parent().get_node("GameState")
var coin_label: Label
var net_label: Label

func _make_panel_label(text_: String, pos: Vector2, icon: String) -> Label:
    var panel := PanelContainer.new()
    panel.position = pos
    panel.custom_minimum_size = Vector2(168, 40)

    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.055, 0.075, 0.10, 0.88)
    style.border_color = Color(1.0, 0.78, 0.22, 0.9)
    style.set_border_width_all(2)
    style.corner_radius_top_left = 11
    style.corner_radius_top_right = 11
    style.corner_radius_bottom_left = 11
    style.corner_radius_bottom_right = 11
    style.content_margin_left = 11
    style.content_margin_right = 11
    style.content_margin_top = 5
    style.content_margin_bottom = 5
    panel.add_theme_stylebox_override("panel", style)

    var label := Label.new()
    label.text = icon + "  " + text_
    label.add_theme_font_size_override("font_size", 18)
    label.add_theme_color_override("font_color", Color("fff4d6"))
    label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.75))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    panel.add_child(label)
    add_child(panel)
    return label

func _ready() -> void:
    catch_label.hide()
    game_state.catches_changed.connect(_on_catches_changed)
    game_state.coins_changed.connect(_on_coins_changed)
    game_state.net_level_changed.connect(_on_net_level_changed)
    catch_label = _make_panel_label("Поймано: 0", Vector2(18, 18), "◎")
    coin_label = _make_panel_label("Монеты: 0", Vector2(18, 64), "●")
    net_label = _make_panel_label("Сеть: I", Vector2(18, 110), "◇")
    _on_catches_changed(game_state.catches)
    _on_coins_changed(game_state.coins)
    _on_net_level_changed(game_state.net_level)

func _on_catches_changed(total: int) -> void:
    catch_label.text = "◎  Поймано: %d" % total

func _on_coins_changed(total: int) -> void:
    coin_label.text = "●  Монеты: %d" % total

func _on_net_level_changed(level: int) -> void:
    var roman := "I"
    if level == 2:
        roman = "II"
    elif level >= 3:
        roman = "III"
    net_label.text = "◇  Сеть: %s" % roman
