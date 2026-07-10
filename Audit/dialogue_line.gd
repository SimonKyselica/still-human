class_name DialogueLine
extends Resource

## One line of an interview transcript shown in the audit terminal.

## Who is speaking. Conventionally "AGENT" (the auditor) or "UNIT".
@export var speaker: String = "AGENT"

## The spoken text.
@export_multiline var text: String = ""

## Optional claim inside [member text] that the player can click to compare
## against other details (the "compare" mechanic). Leave empty for a plain,
## non-clickable line. The string must appear verbatim inside [member text].
@export var detail: String = ""
