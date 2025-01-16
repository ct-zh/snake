extends Node2D

var direction = Vector2.RIGHT
var last_direction = Vector2.RIGHT
var body = []
var growing = false
var move_timer = 0
var move_delay = 0.2

# 添加网格相关变量
var cell_size = 32
var grid_size = Vector2(20, 15)

# 添加音效
var eat_sound
var die_sound

func _ready():
	# 初始化音效
	eat_sound = AudioStreamPlayer.new()
	#eat_sound.stream = preload("res://assets/sounds/eat.wav")  # 需要添加音效文件
	
	die_sound = AudioStreamPlayer.new()
	#die_sound.stream = preload("res://assets/sounds/die.wav")  # 需要添加音效文件
	
	add_child(eat_sound)
	add_child(die_sound)
	
	# 初始化蛇的身体
	var head = create_segment(Vector2(5, 5))
	body.append(head)

func create_segment(pos):
	var segment = ColorRect.new()
	segment.size = Vector2(30, 30)  # 稍小于格子大小，留出边框
	segment.position = pos * cell_size  # 使用cell_size变量
	segment.color = Color.GREEN
	add_child(segment)
	return segment

func _process(delta):
	# 改进方向控制，防止反向移动
	var new_direction = direction
	if Input.is_action_just_pressed("ui_up") and last_direction != Vector2.DOWN:
		new_direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down") and last_direction != Vector2.UP:
		new_direction = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left") and last_direction != Vector2.RIGHT:
		new_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right") and last_direction != Vector2.LEFT:
		new_direction = Vector2.RIGHT
	
	direction = new_direction
	
	move_timer += delta
	if move_timer >= move_delay:
		move_timer = 0
		move()
		last_direction = direction

func move():
	var new_head_pos = body[0].position / cell_size + direction
	
	# 检查边界碰撞
	if new_head_pos.x < 0 or new_head_pos.x >= grid_size.x or \
	   new_head_pos.y < 0 or new_head_pos.y >= grid_size.y:
		game_over()
		return
	
	# 检查食物碰撞
	var food = get_node("/root/Main/Food")
	if food:
		var food_pos = food.position / cell_size  # 将食物位置转换为网格坐标
		if new_head_pos == food_pos:  # 直接比较网格坐标
			growing = true
			food.queue_free()
			get_parent().spawn_food()
			# 播放吃食物音效
			eat_sound.play()
			# 更新分数
			get_parent().get_node("UI").update_score(body.size())
	
	# 移动身体
	var new_head = create_segment(new_head_pos)
	body.push_front(new_head)
	
	# 检查自身碰撞
	for i in range(1, body.size()):
		if body[i].position == new_head.position:
			game_over()
			return
	
	if not growing:
		var tail = body.pop_back()
		tail.queue_free()
	else:
		growing = false

func game_over():
	die_sound.play()
	get_parent().get_node("UI").show_game_over()
	set_process(false)  # 停止处理输入
