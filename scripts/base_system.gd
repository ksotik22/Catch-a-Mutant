extends Node

var state: Node
var bank_label: Label3D
var slot_labels: Array[Label3D] = []
var e_was_down := false
var player: CharacterBody3D
var collector_pos := Vector3(-12, 0.5, 11)

func _ready() -> void:
    call_deferred("build_base")

func mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.85
    return m

func add_box(root: Node, pos: Vector3, size_: Vector3, color: Color) -> void:
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size_
    mesh.material = mat(color)
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    root.add_child(mesh_instance)

func build_base() -> void:
    await get_tree().process_frame
    var root := get_tree().current_scene
    state = root.get_node_or_null("GameState")
    player = root.get_node_or_null("Player") as CharacterBody3D
    if state == null:
        return

    add_box(root, Vector3(-12,0.12,14), Vector3(11,0.22,8), Color("d6bd78"))
    add_box(root, Vector3(-12,0.25,10.4), Vector3(11,0.45,0.35), Color("704322"))
    add_box(root, Vector3(-17.3,0.25,14), Vector3(0.35,0.45,8), Color("704322"))
    add_box(root, Vector3(-6.7,0.25,14), Vector3(0.35,0.45,8), Color("704322"))

    var title := Label3D.new()
    title.text = "БАЗА МУТАНТОВ"
    title.position = Vector3(-12,2.5,10.5)
    title.font_size = 30
    title.pixel_size = 0.004
    title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    title.outline_size = 5
    root.add_child(title)

    var slots := [Vector3(-15,0.6,13),Vector3(-9,0.6,13),Vector3(-15,0.6,16),Vector3(-9,0.6,16)]
    for i in 4:
        add_box(root, slots[i] - Vector3(0,0.48,0), Vector3(3.5,0.18,2.5), Color("55a94c"))
        var label := Label3D.new()
        label.position = slots[i] + Vector3(0,1.0,0)
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        label.font_size = 22
        label.pixel_size = 0.003
        label.outline_size = 4
        root.add_child(label)
        slot_labels.append(label)

    add_box(root, collector_pos, Vector3(3.5,0.35,2.2), Color("ffc94d"))
    bank_label = Label3D.new()
    bank_label.position = collector_pos + Vector3(0,1.25,0)
    bank_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    bank_label.font_size = 24
    bank_label.pixel_size = 0.0032
    bank_label.outline_size = 4
    root.add_child(bank_label)

    state.collection_changed.connect(refresh)
    state.bank_changed.connect(_on_bank_changed)
    refresh()
    _on_bank_changed(state.bank_coins)

func refresh() -> void:
    if state == null:
        return
    for i in slot_labels.size():
        if i < state.collection.size():
            var mutant: Dictionary = state.collection[i]
            var mutation := str(mutant.get("mutation", ""))
            var mutation_text := "" if mutation.is_empty() else " • " + mutation
            slot_labels[i].text = "%s\n%s%s\n+%d монет/сек" % [mutant.get("name","Мутант"), mutant.get("rarity","Обычный"), mutation_text, int(mutant.get("income",1))]
        else:
            slot_labels[i].text = "ПУСТОЙ СЛОТ"

func _on_bank_changed(total: int) -> void:
    if bank_label != null:
        bank_label.text = "КОПИЛКА\n%d монет\nE — ЗАБРАТЬ" % total

func _process(_delta: float) -> void:
    if player == null or state == null:
        return
    var close := player.global_position.distance_to(collector_pos) < 3.0
    var e_down := Input.is_key_pressed(KEY_E)
    if close and e_down and not e_was_down:
        state.collect_bank()
    e_was_down = e_down
