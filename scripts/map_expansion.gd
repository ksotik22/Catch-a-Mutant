extends Node

func mat(c: Color, rough := 0.9) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = rough
    return m

func box(parent: Node, pos: Vector3, size: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    n.rotation_degrees = rot
    parent.add_child(n)
    return n

func cylinder(parent: Node, pos: Vector3, radius: float, height: float, material: Material, segments := 16) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius * 1.05
    mesh.height = height
    mesh.radial_segments = segments
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    parent.add_child(n)
    return n

func sphere(parent: Node, pos: Vector3, scale_: Vector3, material: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 10
    mesh.rings = 6
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    n.scale = scale_
    parent.add_child(n)
    return n

func palm(parent: Node, pos: Vector3, wood: Material, green: Material, scale_ := 1.0) -> void:
    var trunk := cylinder(parent, pos + Vector3(0, 2.1 * scale_, 0), 0.24 * scale_, 4.2 * scale_, wood, 8)
    trunk.rotation_degrees.z = randf_range(-7.0, 7.0)
    for i in 6:
        var a := float(i) * 60.0
        var leaf := box(parent, pos + Vector3(0, 4.25 * scale_, 0), Vector3(0.45, 0.13, 2.8) * scale_, green, Vector3(-7, a, 0))
        leaf.position += Vector3(sin(deg_to_rad(a)) * 0.9, 0, cos(deg_to_rad(a)) * 0.9) * scale_

func _ready() -> void:
    call_deferred("build")

func build() -> void:
    await get_tree().process_frame
    var root := get_tree().current_scene
    if root == null or root.has_node("MapExpansionDone"):
        return
    var marker := Node.new()
    marker.name = "MapExpansionDone"
    root.add_child(marker)

    var grass := mat(Color("46b83f"))
    var grass_dark := mat(Color("248c38"))
    var sand := mat(Color("e7c574"))
    var stone := mat(Color("66747c"))
    var stone_light := mat(Color("8c999e"))
    var wood := mat(Color("704322"))
    var green := mat(Color("25a83d"))
    var green_light := mat(Color("6bc83d"))
    var path := mat(Color("d7b36a"))

    # Main island becomes much wider than the original 20m-radius play area.
    cylinder(root, Vector3(0, -1.45, -5), 37.0, 2.0, stone, 28)
    cylinder(root, Vector3(0, -0.50, -5), 35.5, 0.55, sand, 28)
    cylinder(root, Vector3(0, -0.20, -5), 33.8, 0.55, grass, 28)

    # Physical floor for the enlarged land.
    var ground := StaticBody3D.new()
    ground.name = "ExpandedIslandCollision"
    ground.position = Vector3(0, -0.7, -5)
    var shape_node := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = 33.5
    shape.height = 1.8
    shape_node.shape = shape
    ground.add_child(shape_node)
    root.add_child(ground)

    # Long routes leading away from the lighthouse plaza.
    box(root, Vector3(0, 0.12, -18), Vector3(4.0, 0.12, 28.0), path)
    box(root, Vector3(-17, 0.13, -13), Vector3(23.0, 0.12, 3.2), path, Vector3(0, 28, 0))
    box(root, Vector3(17, 0.13, -13), Vector3(23.0, 0.12, 3.2), path, Vector3(0, -28, 0))

    # Left tropical grove.
    for p in [Vector3(-20,0,-7),Vector3(-25,0,-12),Vector3(-18,0,-18),Vector3(-27,0,-22),Vector3(-20,0,-27),Vector3(-29,0,-5)]:
        palm(root, p, wood, green, randf_range(0.85, 1.15))
    for p in [Vector3(-23,0.7,-8),Vector3(-28,0.7,-16),Vector3(-19,0.7,-22),Vector3(-25,0.7,-27),Vector3(-15,0.7,-14)]:
        sphere(root, p, Vector3(2.3,1.2,1.8), green_light)

    # Right rocky coast - future tougher mutant zone.
    for p in [Vector3(20,0.7,-8),Vector3(26,0.8,-12),Vector3(21,0.9,-18),Vector3(28,0.7,-22),Vector3(18,0.8,-27),Vector3(29,0.7,-5)]:
        sphere(root, p, Vector3(randf_range(2.4,4.2),randf_range(1.8,3.0),randf_range(2.2,3.8)), stone if randf() > 0.5 else stone_light)
    for p in [Vector3(16,0,-11),Vector3(25,0,-18),Vector3(17,0,-25)]:
        palm(root, p, wood, green, 0.9)

    # Far clearing reserved for rare/legendary content later.
    cylinder(root, Vector3(0, 0.02, -29), 8.0, 0.22, grass_dark, 18)
    for p in [Vector3(-8,0,-29),Vector3(8,0,-29),Vector3(-6,0,-34),Vector3(6,0,-34)]:
        palm(root, p, wood, green, 1.05)
    for p in [Vector3(-9,0.7,-24),Vector3(10,0.7,-25),Vector3(-10,0.7,-34),Vector3(10,0.7,-34)]:
        sphere(root, p, Vector3(2.8,1.7,2.4), stone)

    # Small scenic ruins at the far end, later usable as an unlockable zone.
    for x in [-4.5, 4.5]:
        cylinder(root, Vector3(x,1.5,-31), 0.55, 3.0, stone_light, 8)
    box(root, Vector3(0,3.0,-31), Vector3(10.0,0.65,1.0), stone_light)

    # More coastal vegetation to break up the huge open circle.
    for p in [Vector3(-30,0,-1),Vector3(-31,0,-15),Vector3(-30,0,-29),Vector3(30,0,-2),Vector3(31,0,-16),Vector3(29,0,-29),Vector3(-15,0,-35),Vector3(15,0,-35)]:
        palm(root, p, wood, green, 0.9)
