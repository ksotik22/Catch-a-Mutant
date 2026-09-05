extends Node

func _ready() -> void:
    call_deferred("build")

func mat(color: Color, roughness := 0.8) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m

func box(parent: Node, name_: String, pos: Vector3, size: Vector3, material: Material, rot := Vector3.ZERO) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name_
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    n.rotation_degrees = rot
    parent.add_child(n)
    return n

func sphere(parent: Node, name_: String, pos: Vector3, scale_: Vector3, material: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name_
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

func cylinder(parent: Node, name_: String, pos: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = name_
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius * 1.08
    mesh.height = height
    mesh.radial_segments = 10
    mesh.material = material
    n.mesh = mesh
    n.position = pos
    parent.add_child(n)
    return n

func build() -> void:
    var root := get_tree().current_scene
    if root == null or root.has_node("VisualUpgradeDone"):
        return
    var marker := Node.new()
    marker.name = "VisualUpgradeDone"
    root.add_child(marker)

    var cream := mat(Color(1.0, 0.86, 0.55))
    var dark := mat(Color(0.12, 0.18, 0.22))
    var white := mat(Color(0.98, 0.95, 0.86))
    var red := mat(Color(0.93, 0.16, 0.09))
    var blue := mat(Color(0.08, 0.48, 0.82))
    var teal := mat(Color(0.03, 0.66, 0.58))
    var wood := mat(Color(0.36, 0.16, 0.06))
    var green := mat(Color(0.05, 0.62, 0.18))
    var light_green := mat(Color(0.22, 0.82, 0.28))
    var orange := mat(Color(1.0, 0.48, 0.08))
    var pink := mat(Color(1.0, 0.42, 0.55))
    var yellow := mat(Color(1.0, 0.78, 0.12))

    # Player: replace the blue placeholder cube with a chunky explorer.
    var player := root.get_node_or_null("Player")
    if player != null:
        var old_mesh := player.get_node_or_null("Mesh")
        if old_mesh != null:
            old_mesh.visible = false
        sphere(player, "Body", Vector3(0, 0.05, 0), Vector3(1.0, 1.25, 0.72), blue)
        sphere(player, "Head", Vector3(0, 1.0, 0), Vector3(0.78, 0.78, 0.72), cream)
        box(player, "Hair", Vector3(0, 1.36, 0.02), Vector3(0.72, 0.22, 0.66), dark)
        box(player, "Backpack", Vector3(0, 0.18, 0.52), Vector3(0.72, 0.82, 0.28), red)
        sphere(player, "LeftArm", Vector3(-0.62, 0.15, 0), Vector3(0.28, 0.8, 0.28), cream)
        sphere(player, "RightArm", Vector3(0.62, 0.15, 0), Vector3(0.28, 0.8, 0.28), cream)
        sphere(player, "LeftLeg", Vector3(-0.27, -0.78, 0), Vector3(0.34, 0.75, 0.38), dark)
        sphere(player, "RightLeg", Vector3(0.27, -0.78, 0), Vector3(0.34, 0.75, 0.38), dark)

    # Cat Loaf: turn the orange ball into a recognizable silly mutant.
    var creature := root.get_node_or_null("CatLoaf")
    if creature != null:
        var cm := creature.get_node_or_null("Mesh")
        if cm != null:
            cm.visible = false
        sphere(creature, "LoafBody", Vector3.ZERO, Vector3(1.45, 0.9, 1.0), orange)
        sphere(creature, "Face", Vector3(0, 0.28, -0.58), Vector3(0.78, 0.72, 0.45), orange)
        box(creature, "EarL", Vector3(-0.34, 0.78, -0.55), Vector3(0.28, 0.42, 0.18), orange, Vector3(0, 0, -22))
        box(creature, "EarR", Vector3(0.34, 0.78, -0.55), Vector3(0.28, 0.42, 0.18), orange, Vector3(0, 0, 22))
        sphere(creature, "EyeL", Vector3(-0.22, 0.38, -0.82), Vector3(0.13, 0.16, 0.08), dark)
        sphere(creature, "EyeR", Vector3(0.22, 0.38, -0.82), Vector3(0.13, 0.16, 0.08), dark)
        sphere(creature, "Nose", Vector3(0, 0.17, -0.87), Vector3(0.13, 0.1, 0.07), pink)

    # Lighthouse details: lantern room, cap and windows.
    cylinder(root, "LanternRoom", Vector3(0, 9.55, 0), 1.15, 0.95, dark)
    cylinder(root, "LanternGlow", Vector3(0, 9.55, 0), 0.88, 0.72, yellow)
    cylinder(root, "LanternRoof", Vector3(0, 10.18, 0), 1.45, 0.28, red)
    box(root, "LighthouseDoor", Vector3(0, 1.15, 2.0), Vector3(1.05, 1.9, 0.18), blue)
    box(root, "LighthouseWindow", Vector3(0, 5.0, 1.68), Vector3(0.7, 0.85, 0.12), dark)

    # Shop fronts, awnings and signs.
    box(root, "SellFront", Vector3(-7, 1.35, 3.12), Vector3(3.4, 1.45, 0.18), white)
    box(root, "SellCounter", Vector3(-7, 1.15, 3.45), Vector3(3.8, 0.32, 0.7), wood)
    box(root, "SellAwning", Vector3(-7, 2.35, 3.42), Vector3(4.0, 0.25, 0.85), red, Vector3(-10, 0, 0))
    box(root, "SellSign", Vector3(-7, 3.8, 1.45), Vector3(2.8, 0.75, 0.22), red)
    box(root, "UpgradeFront", Vector3(7, 1.35, 3.12), Vector3(3.4, 1.45, 0.18), white)
    box(root, "UpgradeCounter", Vector3(7, 1.15, 3.45), Vector3(3.8, 0.32, 0.7), wood)
    box(root, "UpgradeAwning", Vector3(7, 2.35, 3.42), Vector3(4.0, 0.25, 0.85), blue, Vector3(-10, 0, 0))
    box(root, "UpgradeSign", Vector3(7, 3.8, 1.45), Vector3(2.8, 0.75, 0.22), blue)

    # Tropical clutter: bushes, flowers, crates and dock-like boards.
    var bushes := [Vector3(-10,0.65,4), Vector3(10,0.65,4), Vector3(-6,0.65,-9), Vector3(5,0.65,-12), Vector3(12,0.65,-11), Vector3(-13,0.65,11)]
    for i in bushes.size():
        sphere(root, "Bush%d" % i, bushes[i], Vector3(1.6, 0.9, 1.3), green if i % 2 == 0 else light_green)
    var flowers := [Vector3(-4,0.5,7), Vector3(4,0.5,8), Vector3(-9,0.5,-4), Vector3(9,0.5,-5)]
    for i in flowers.size():
        sphere(root, "Flower%d" % i, flowers[i], Vector3(0.35,0.35,0.35), pink if i % 2 == 0 else yellow)
    box(root, "Crate1", Vector3(-9.6,0.65,3.1), Vector3(1.2,1.2,1.2), wood, Vector3(0,18,0))
    box(root, "Crate2", Vector3(9.7,0.55,3.0), Vector3(1.0,1.0,1.0), wood, Vector3(0,-14,0))
    box(root, "Pier1", Vector3(0,-0.15,17.5), Vector3(5.0,0.25,0.8), wood)
    box(root, "Pier2", Vector3(0,-0.15,19.0), Vector3(5.0,0.25,0.8), wood)
    box(root, "Pier3", Vector3(0,-0.15,20.5), Vector3(5.0,0.25,0.8), wood)

    # Softer tropical sky/fog background without external assets.
    var world_env := WorldEnvironment.new()
    world_env.name = "TropicalEnvironment"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.35, 0.78, 0.96)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.86, 1.0)
    env.ambient_light_energy = 0.55
    world_env.environment = env
    root.add_child(world_env)
