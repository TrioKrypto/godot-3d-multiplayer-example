extends Spatial

onready var Player = load("res://Player.tscn")

puppet func spawn_player(spawn_pos, id):
	var player = Player.instance()
	
	player.translation = spawn_pos
	player.name = String(id) # Important
	player.set_network_master(id) # Important
	
	$Players.add_child(player)
	
	print("Player spawned, ID: "+str(id))
