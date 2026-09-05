extends Area3D

@export var speed := 12.0
@export var lifetime := 2.5
var direction := Vector3.ZERO

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    var from := global_position
    var to := from + direction * speed * delta

    var query := PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    query.collision_mask = 1
    query.collide_with_bodies = true
    query.collide_with_areas = false
    query.exclude = [get_rid()]

    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        var body = hit.get("collider")
        if body != null and body.has_method("catch_creature"):
            body.catch_creature()
            queue_free()
            return

    global_position = to
    lifetime -= delta
    if lifetime <= 0.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if body.has_method("catch_creature"):
        body.catch_creature()
        queue_free()
