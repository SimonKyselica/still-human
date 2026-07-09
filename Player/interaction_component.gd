class_name InteractionComponent
extends Node

## Where the ray is cast from / which direction it points. Defaults to the
## parent node (your Camera3D) if left empty in the Inspector.
@export var ray_origin: Node3D
@export var interaction_range: float = 3.0


@export_flags_3d_physics var collision_mask: int = 1


signal target_changed(interactable: Interactable)

var current_target: Interactable = null


func _ready() -> void:
	if ray_origin == null:
		ray_origin = get_parent() as Node3D


func _physics_process(_delta: float) -> void:
	_update_target()


func _update_target() -> void:
	var space_state := ray_origin.get_world_3d().direct_space_state
	var from := ray_origin.global_transform.origin
	var to := from - ray_origin.global_transform.basis.z * interaction_range

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	var result := space_state.intersect_ray(query)

	var new_target: Interactable = null
	if result and result.collider is Interactable:
		var candidate: Interactable = result.collider
		if candidate.can_interact():
			new_target = candidate

	if new_target != current_target:
		current_target = new_target
		target_changed.emit(current_target)


## Call this from the player's input handling when the "interact" action fires.
func try_interact(player: Node) -> void:
	if current_target != null and current_target.can_interact():
		current_target.interact(player)
