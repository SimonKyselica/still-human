class_name DayTask
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_enum("CHORE", "TERMINAL", "PHONE", "SLEEP") var phase: String = "CHORE"
