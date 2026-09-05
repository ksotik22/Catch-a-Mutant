extends Area3D

@export var speed := 12.0
@export var lifetime := 2.5
var direction := Vector3.ZERO
var net_level: int = 1

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _try_catch(body: Node) -> bool:
    if body == null or not body.has_method("catch_creature"):
        return false
    var caught_now: bool = body.catch_creature(net_level)
    if not caught_now and body.has_method("can_be_caught"):
        print("Нужна сеть уровня ", body.required_net_level)
    return caught_now

func _physics_process(delta: float) -> void:
    var from := global_position
    var to := from + direction * speed * delta

    var query := PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    query.collision_mask = 4
    query.collide_with_bodies = true
    query.collide_with_areas = false
    query.exclude = [get_rid()]

    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        var body = hit.get("collider")
        _try_catch(body)
        queue_free()
        return

    global_position = to
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if _try_catch(body):
        queue_free()
