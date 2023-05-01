extends CanvasLayer

func _process(delta):
	$HBoxContainer/Label.text = str(Nodo.coins)
