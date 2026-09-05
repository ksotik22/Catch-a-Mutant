extends CharacterBody3D

@export var creature_name := "Кот Батон"
@export var wander_speed := 2.2
@export var wander_radius := 7.0
@export var required_net_level: int = 1

var origin := Vector3.ZERO
var target := Vector3.ZERO
var wait_time := 0.0
var caught := false
var rarity_name := "Обычный"
var rarity_multiplier: int = 1
var rarity_color := Color("e8e8e8")
var name_label: Label3D

func _ready() -> void:
    origin = global_position
    _ensure_name_label()
    _roll_rarity()
    _pick_target()

func _ensure_name_label() -> void:
    for child in get_children():
        if child is Label3D:
            name_label = child
            break
    if name_label == null:
        name_label = Label3D.new()
        name_label.position = Vector3(0, 2.0, 0)
        name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        name_label.no_depth_test = false
        name_label.fixed_size = false
        name_label.pixel_size = 0.0045
        add_child(name_label)

func _roll_rarity() -> void:
    var roll := randf() * 100.0
    if roll < 1.0:
        rarity_name = "Мифический"
        rarity_multiplier = 15
        rarity_color = Color("ff4fd8")
    elif roll < 4.0:
        rarity_name = "Легендарный"
        rarity_multiplier = 8
        rarity_color = Color("ffb52e")
    elif roll < 12.0:
        rarity_name = "Эпический"
        rarity_multiplier = 4
        rarity_color = Color("b56cff")
    elif roll < 32.0:
        rarity_name = "Редкий"
        rarity_multiplier = 2
        rarity_color = Color("4da6ff")
    else:
        rarity_name = "Обычный"
        rarity_multiplier = 1
        rarity_color = Color("e8e8e8")
    _update_name_label()

func _update_name_label() -> void:
    if name_label == null:
        return
    name_label.text = "%s\n%s  x%d" % [creature_name, rarity_name, rarity_multiplier]
    name_label.modulate = rarity_color
    name_label.font_size = 28
    name_label.outline_modulate = Color("20242b")
    name_label.outline_size = 5
    name_label.fixed_size = false
    name_label.pixel_size = 0.0045

func can_be_caught(net_level: int) -> bool:
    return net_level >= required_net_level and not caught

func _physics_process(delta: float) -> void:
    if caught:
        return
    if not is_on_floor():
        velocity += get_gravity() * delta
    var flat_target := Vector3(target.x, global_position.y, target.z)
    var direction := global_position.direction_to(flat_target)
    if global_position.distance_to(flat_target) > 0.6:
        velocity.x = direction.x * wander_speed
        velocity.z = direction.z * wander_speed
        if direction.length() > 0.1:
            rotation.y = atan2(direction.x, direction.z)
    else:
        velocity.x = 0.0
        velocity.z = 0.0
        wait_time -= delta
        if wait_time <= 0.0:
            _pick_target()
    move_and_slide()

func _pick_target() -> void:
    var angle := randf() * TAU
    var distance := randf_range(2.0, wander_radius)
    target = origin + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
    wait_time = randf_range(0.5, 1.8)

func catch_creature(net_level: int = 1) -> bool:
    if not can_be_caught(net_level):
        return false
    caught = true
    var state = get_tree().current_scene.get_node_or_null("GameState")
    if state != null:
        state.add_catch(10 * rarity_multiplier)
    print("Пойман: ", creature_name, " [", rarity_name, "] x", rarity_multiplier)
    _respawn_after_delay()
    return true

func _respawn_after_delay() -> void:
    visible = false
    collision_layer = 0
    collision_mask = 0
    velocity = Vector3.ZERO
    await get_tree().create_timer(5.0).timeout
    global_position = origin
    collision_layer = 4
    collision_mask = 1
    visible = true
    caught = false
    _roll_rarity()
    _pick_target()
