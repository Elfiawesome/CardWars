extends Room

func _process(delta:float) -> void:
	$Camera3D.rotation += Vector3(randi_range(-3,3),randi_range(-3,3),randi_range(-3,3))*0.001
