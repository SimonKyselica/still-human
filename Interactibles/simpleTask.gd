class_name SimpleTask
extends Interactable

@export var say_lines: Array[String] = []
@export var say_sfx: AudioStream
@export var say_pos: Vector2 = Vector2(960, 900)

func _ready() -> void:
	add_to_group("tasks_objects")
	
func interact(player: Node) -> void:
	super.interact(player)
	if task_id == "eat":
		# Zjedené = zmizne. queue_free() na self zmazal len StaticBody3D s
		# colliderom — ten sedí VNÚTRI modelu, takže burger zostal ležať na
		# stole a len prestal byť klikateľný. Treba zmazať celú rekvizitu.
		enabled = false   # kým sa free vykoná (na konci rámca), nedá sa jesť dvakrát
		_prop_root().queue_free()
	if not say_lines.is_empty():
		DialogueManager.start_dialog(say_pos, say_lines, say_sfx)
	GameState.complete_task(task_id)


## Koreň rekvizity, teda to, čo hráč naozaj vidí: koreň Burger.tscn / Bottle.tscn.
## `owner` je koreň scény, v ktorej bol tento StaticBody3D vytvorený — presne on.
##
## Tá poistka na current_scene tam musí byť: keby `owner` niekedy ukazoval na
## koreň Main.tscn (iné zavesenie rekvizity, editable children), zmazala by sa
## celá izba. V takom prípade radšej padneme na pôvodné správanie.
func _prop_root() -> Node:
	if owner == null or owner == get_tree().current_scene:
		return self
	return owner
