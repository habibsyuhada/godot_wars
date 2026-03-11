extends Button

@export var button_text: String = "Button":
	set(value):
		button_text = value
		if is_inside_tree():
			text = button_text

func _ready() -> void:
	text = button_text
