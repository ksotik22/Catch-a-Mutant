extends Node

var root: Node3D
var game_state: Node
var player: CharacterBody3D
var sell_zone: Area3D
var prompt: Label
var player_in_sell_zone := false

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
    _make_sell_zone()
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

func _make_sell_zone() -> void:
    sell_zone = Area3D.new()
    sell_zone.name = "SellZone"
    sell_zone.position = Vector3(-7, 1.0, 6.2)
    sell_zone.collision_layer = 0
    sell_zone.collision_mask = 1
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(5.5, 2.2, 2.8)
    collision.shape = shape
    sell_zone.add_child(collision)
    root.add_child(sell_zone)
    sell_zone.body_entered.connect(_on_sell_entered)
    sell_zone.body_exited.connect(_on_sell_exited)

func _make_prompt() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 20
    root.add_child(layer)
    prompt = Label.new()
    prompt.text = ""
    prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    prompt.add_theme_font_size_override("font_size", 28)
    prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt.position = Vector2(-260, -115)
    prompt.size = Vector2(520, 55)
    layer.add_child(prompt)

func _process(_delta: float) -> void:
    if not player_in_sell_zone:
        return
    if Input.is_key_pressed(KEY_E):
        _sell_all()

func _on_sell_entered(body: Node3D) -> void:
    if body != player:
        return
    player_in_sell_zone = true
    prompt.text = "E — продать всех мутантов"

func _on_sell_exited(body: Node3D) -> void:
    if body != player:
        return
    player_in_sell_zone = false
    prompt.text = ""

func _sell_all() -> void:
    if game_state == null or game_state.catches <= 0:
        prompt.text = "Нет пойманных мутантов"
        return
    var sold: int = game_state.sell_all()
    prompt.text = "Продано: %d   +%d монет" % [sold, sold * 10]
    await get_tree().create_timer(1.2).timeout
    if player_in_sell_zone:
        prompt.text = "E — продать всех мутантов"
