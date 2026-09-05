extends Node

var root: Node3D
var game_state: Node
var player: CharacterBody3D
var sell_zone: Area3D
var upgrade_zone: Area3D
var prompt: Label
var player_in_sell_zone := false
var player_in_upgrade_zone := false
var e_was_down := false

func _ready() -> void:
    call_deferred("build")

func build() -> void:
    root = get_tree().current_scene
    game_state = root.get_node_or_null("GameState")
    player = root.get_node_or_null("Player")
    if root == null or player == null:
        return
    _add_static_box("SellShopHitbox", Vector3(-7, 1.5, 3.2), Vector3(5.8, 3.0, 3.6))
    _add_static_box("UpgradeShopHitbox", Vector3(7, 1.5, 3.2), Vector3(5.8, 3.0, 3.6))
    _add_static_cylinder("LighthouseHitbox", Vector3(0, 4.0, 0), 1.75, 8.0)
    sell_zone = _make_zone("SellZone", Vector3(-7, 1.0, 6.2))
    upgrade_zone = _make_zone("UpgradeZone", Vector3(7, 1.0, 6.2))
    sell_zone.body_entered.connect(_on_sell_entered)
    sell_zone.body_exited.connect(_on_sell_exited)
    upgrade_zone.body_entered.connect(_on_upgrade_entered)
    upgrade_zone.body_exited.connect(_on_upgrade_exited)
    _make_prompt()

func _add_static_box(name_: String, pos: Vector3, size_: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = name_
    body.position = pos
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size_
    collision.shape = shape
    body.add_child(collision)
    root.add_child(body)

func _add_static_cylinder(name_: String, pos: Vector3, radius_: float, height_: float) -> void:
    var body := StaticBody3D.new()
    body.name = name_
    body.position = pos
    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = radius_
    shape.height = height_
    collision.shape = shape
    body.add_child(collision)
    root.add_child(body)

func _make_zone(name_: String, pos: Vector3) -> Area3D:
    var zone := Area3D.new()
    zone.name = name_
    zone.position = pos
    zone.collision_layer = 0
    zone.collision_mask = 1
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(5.5, 2.2, 2.8)
    collision.shape = shape
    zone.add_child(collision)
    root.add_child(zone)
    return zone

func _make_prompt() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 20
    root.add_child(layer)
    prompt = Label.new()
    prompt.text = ""
    prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt.add_theme_font_size_override("font_size", 20)
    prompt.add_theme_color_override("font_color", Color("fff4d6"))
    prompt.add_theme_color_override("font_shadow_color", Color(0,0,0,0.9))
    prompt.add_theme_constant_override("shadow_offset_x", 2)
    prompt.add_theme_constant_override("shadow_offset_y", 2)
    prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt.position = Vector2(-310, -105)
    prompt.size = Vector2(620, 45)
    layer.add_child(prompt)

func _process(_delta: float) -> void:
    var e_down := Input.is_key_pressed(KEY_E)
    if e_down and not e_was_down:
        if player_in_sell_zone:
            _sell_all()
        elif player_in_upgrade_zone:
            _buy_upgrade()
    e_was_down = e_down

func _on_sell_entered(body: Node3D) -> void:
    if body != player:
        return
    player_in_sell_zone = true
    _refresh_prompt()

func _on_sell_exited(body: Node3D) -> void:
    if body != player:
        return
    player_in_sell_zone = false
    _refresh_prompt()

func _on_upgrade_entered(body: Node3D) -> void:
    if body != player:
        return
    player_in_upgrade_zone = true
    _refresh_prompt()

func _on_upgrade_exited(body: Node3D) -> void:
    if body != player:
        return
    player_in_upgrade_zone = false
    _refresh_prompt()

func _refresh_prompt() -> void:
    if player_in_sell_zone:
        prompt.text = "E — ПРОДАТЬ ПОЙМАННЫХ"
    elif player_in_upgrade_zone:
        if game_state.net_level >= 3:
            prompt.text = "СЕТЬ III — МАКСИМАЛЬНЫЙ УРОВЕНЬ"
        else:
            prompt.text = "E — УЛУЧШИТЬ СЕТЬ ДО %d УР.  •  %d МОНЕТ" % [game_state.net_level + 1, game_state.next_net_price()]
    else:
        prompt.text = ""

func _sell_all() -> void:
    if game_state == null or game_state.catches <= 0:
        prompt.text = "НЕТ ПОЙМАННЫХ МУТАНТОВ"
        return
    var payout: int = game_state.stored_value
    var sold: int = game_state.sell_all()
    prompt.text = "ПРОДАНО: %d  •  +%d МОНЕТ" % [sold, payout]
    await get_tree().create_timer(1.1).timeout
    _refresh_prompt()

func _buy_upgrade() -> void:
    if game_state.net_level >= 3:
        prompt.text = "СЕТЬ УЖЕ МАКСИМАЛЬНАЯ"
        return
    var price: int = game_state.next_net_price()
    if game_state.buy_net_upgrade():
        prompt.text = "СЕТЬ УЛУЧШЕНА ДО %d УРОВНЯ!" % game_state.net_level
    else:
        prompt.text = "НУЖНО %d МОНЕТ" % price
    await get_tree().create_timer(1.1).timeout
    _refresh_prompt()
