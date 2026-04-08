class_name Key
extends Interactable

@export var key_id: String = ""   # e.g. "lab_key", "office_key"

func interact():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.num_keys += 1
		print("Picked up key:", key_id, "Total keys:", player.num_keys)
		queue_free()
