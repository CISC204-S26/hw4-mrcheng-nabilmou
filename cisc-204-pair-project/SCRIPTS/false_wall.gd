extends Area2D

var triggered := false

func _on_body_entered(body):
	if body.name != "Player":
		return
	
	if triggered:
		return
	
	triggered = true
	
	for node in get_tree().get_nodes_in_group("secret_hall"):
		node.visible = true
	
	for node in get_tree().get_nodes_in_group("false_wall"):
		node.visible = false
