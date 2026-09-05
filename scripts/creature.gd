extends CharacterBody3D

@export var creature_name := "Кот Батон"
@export var wander_speed := 2.2
@export var wander_radius := 7.0

var origin := Vector3.ZERO
var target := Vector3.ZERO
var wait_time := 0.0
var caught := false

func _ready() -> void:
    origin = global_position
    _pick_target()

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

func catch_creature() -> void:
    if caught:
        return
    caught = true
    var state = get_tree().current_scene.get_node_or_null("GameState")
    if state != null:
        state.add_catch()
    print("Пойман: ", creature_name)
    _respawn_after_delay()

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
    _pick_target()
