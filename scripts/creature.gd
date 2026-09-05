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
var mutation_name := ""
var mutation_multiplier: int = 1
var mutation_color := Color.WHITE
var zone_multiplier: int = 1
var zone_name := "Центр"
var name_label: Label3D
var player: CharacterBody3D

func _ready() -> void:
    collision_layer = 4
    collision_mask = 1
    origin = global_position
    player = get_tree().current_scene.get_node_or_null("Player") as CharacterBody3D
    _upgrade_collision()
    _ensure_name_label()
    _detect_zone()
    _roll_rarity()
    _roll_mutation()
    _update_name_label()
    _pick_target()

func _upgrade_collision() -> void:
    var collision := get_node_or_null("Collision") as CollisionShape3D
    if collision != null:
        var shape := CapsuleShape3D.new()
        shape.radius = 1.05
        shape.height = 2.25
        collision.shape = shape
        collision.position.y = 0.75

func _ensure_name_label() -> void:
    for child in get_children():
        if child is Label3D:
            name_label = child
            break
    if name_label == null:
        name_label = Label3D.new()
        add_child(name_label)
    name_label.position = Vector3(0, 2.15, 0)
    name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    name_label.no_depth_test = false
    name_label.fixed_size = false
    name_label.pixel_size = 0.0027

func _detect_zone() -> void:
    var p := origin
    if p.z < -23.0:
        zone_name = "Руины"
        zone_multiplier = 3
    elif p.x > 14.0:
        zone_name = "Скалы"
        zone_multiplier = 2
    elif p.x < -14.0:
        zone_name = "Джунгли"
        zone_multiplier = 2
    else:
        zone_name = "Центр"
        zone_multiplier = 1

func _roll_rarity() -> void:
    var bonus: float = float(zone_multiplier - 1) * 5.0
    var roll: float = randf() * 100.0 - bonus
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

func _roll_mutation() -> void:
    mutation_name = ""
    mutation_multiplier = 1
    mutation_color = Color.WHITE
    var roll: float = randf() * 100.0
    if roll < 2.0:
        mutation_name = "Электро"
        mutation_multiplier = 5
        mutation_color = Color("62dfff")
    elif roll < 6.0:
        mutation_name = "Огненный"
        mutation_multiplier = 3
        mutation_color = Color("ff7043")
    elif roll < 14.0:
        mutation_name = "Золотой"
        mutation_multiplier = 2
        mutation_color = Color("ffd84a")
    _apply_mutation_visual()

func _apply_mutation_visual() -> void:
    if mutation_name.is_empty():
        return
    for child in get_children():
        if child is MeshInstance3D:
            child.modulate = mutation_color

func _update_name_label() -> void:
    if name_label == null:
        return
    var extra := ""
    if not mutation_name.is_empty():
        extra = "  %s x%d" % [mutation_name, mutation_multiplier]
    name_label.text = "%s\n%s x%d%s" % [creature_name, rarity_name, rarity_multiplier, extra]
    name_label.modulate = mutation_color if not mutation_name.is_empty() else rarity_color
    name_label.font_size = 22
    name_label.outline_modulate = Color("161b22")
    name_label.outline_size = 4

func can_be_caught(net_level: int) -> bool:
    return net_level >= required_net_level and not caught

func _physics_process(delta: float) -> void:
    if caught:
        return
    if not is_on_floor():
        velocity += get_gravity() * delta

    var fleeing: bool = false
    if player != null:
        var distance_to_player: float = global_position.distance_to(player.global_position)
        var notice_distance: float = 4.0 + float(rarity_multiplier) * 0.35
        if rarity_multiplier >= 2 and distance_to_player < notice_distance:
            fleeing = true
            var away: Vector3 = player.global_position.direction_to(global_position)
            away.y = 0.0
            away = away.normalized()
            var flee_bonus: float = 1.25 + minf(float(rarity_multiplier) * 0.06, 0.8)
            velocity.x = away.x * wander_speed * flee_bonus
            velocity.z = away.z * wander_speed * flee_bonus
            if away.length() > 0.1:
                rotation.y = atan2(away.x, away.z)

    if not fleeing:
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
    var value: int = 10 * rarity_multiplier * mutation_multiplier * zone_multiplier
    if state != null:
        state.add_catch(value)
    print("Пойман: ", creature_name, " [", rarity_name, "] ", mutation_name, " = ", value)
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
    _roll_mutation()
    _update_name_label()
    _pick_target()
