extends KinematicBody

var camera_angle = 0
var mouse_sensitivity = 0.3;

var speed = 10;
var acceleration = 20
var gravity = 10

var move_dir = Vector3()
var velocity = Vector3()
var aim = Basis()

puppet var puppet_pos = Vector3()
puppet var puppet_vel = Vector3()
puppet var puppet_aim = Basis()

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_network_master():
		$Head/Camera.current = true
		pass
	else:
		var player_id = get_network_master()
		puppet_pos = translation # Just making sure we initilize it

func _input(event):
	if event is InputEventMouseMotion && is_network_master():
		rotate_y(deg2rad(-event.relative.x*mouse_sensitivity));
		var change = -event.relative.y * mouse_sensitivity;
		if (change + camera_angle) < 90 and (change + camera_angle) > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
			
	if(Input.is_action_just_pressed("quit")):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
		
	#print(aim.get_euler().y)
	#transform.basis = Basis()
	#rotate_object_local(Vector3(0, 1, 0), aim.get_euler().y)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_network_master():
		
		move_dir = Vector3()
		speed = 10;
		
		aim = $Head/Camera.get_global_transform().basis
		
		if Input.is_action_pressed("up"):
			move_dir  -= aim.z
		if Input.is_action_pressed("down"):
			move_dir  += aim.z;	
		if Input.is_action_pressed("left"):
			move_dir -= aim.x;
		if Input.is_action_pressed("right"):
			move_dir  += aim.x;		
		if Input.is_action_pressed("move_sprint"):
			speed = 20
			
		velocity = move_dir.normalized() * speed
		move_and_slide(move_dir.normalized()*speed, Vector3.UP)
		
		print(rotation.y)
		rset_unreliable("puppet_pos", translation)
		rset_unreliable("puppet_vel", velocity)
		rset_unreliable("puppet_aim", aim)
		
		#global_transform.basis.x 
		#global_rotate(Vector3(0,1,0), 50);
		#rotate_object_local(Vector3(0, 1, 0), 50)
		#transform.rotated(Vector3(0,1,0),50)
		#print(rotation)
	else:
		# If we are not the ones controlling this player, 
		# sync to last known position and velocity
		
		#position = puppet_pos
		#velocity = puppet_vel
		#print(translation)
		translation = puppet_pos;
		
		print(puppet_aim.y)
		transform.basis = Basis()
		rotate_object_local(Vector3(0, 1, 0), puppet_aim.get_euler().y)
		
	
	translation += velocity * delta
	
	if not is_network_master():
		# It may happen that many frames pass before the controlling player sends
		# their position again. If we don't update puppet_pos to position after moving,
		# we will keep jumping back until controlling player sends next position update.
		# Therefore, we update puppet_pos to minimize jitter problems
		puppet_pos = translation

