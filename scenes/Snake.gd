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
var collision_tolerance = 0.3  # 碰撞容差，值越大越容易触发碰撞

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
	if (Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("w")) and last_direction != Vector2.DOWN:
		new_direction = Vector2.UP
	elif (Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("s")) and last_direction != Vector2.UP:
		new_direction = Vector2.DOWN
	elif (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("a")) and last_direction != Vector2.RIGHT:
		new_direction = Vector2.LEFT
	elif (Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("d")) and last_direction != Vector2.LEFT:
		new_direction = Vector2.RIGHT
	
	direction = new_direction
	
	move_timer += delta
	if move_timer >= move_delay:
		move_timer = 0
		move()
		last_direction = direction

func is_close_enough(pos1: Vector2, pos2: Vector2) -> bool:
	# 计算两点之间的距离
	var distance = (pos1 - pos2).length()
	# 如果距离小于格子大小乘以容差，则认为足够接近
	return distance < cell_size * collision_tolerance

func move():
	var new_head_pos = body[0].position / cell_size + direction
	
	# 检查边界碰撞
	if new_head_pos.x < 0 or new_head_pos.x >= grid_size.x or \
	   new_head_pos.y < 0 or new_head_pos.y >= grid_size.y:
		game_over()
		return
	
	# 检查食物碰撞
	var food = get_node("/root/Main/GameArea/Food")
	if food:
		var food_pos = food.position / cell_size  # 将食物位置转换为网格坐标
		var head_pos = new_head_pos  # 蛇头网格坐标
		
		# 添加详细的调试信息
		print("\n===== 碰撞检测信息 =====")
		print("蛇头:")
		print("  - 网格坐标: ", head_pos)
		print("  - 实际位置: ", body[0].position if body.size() > 0 else "无")
		print("  - 下一步网格坐标: ", new_head_pos)
		print("  - 下一步实际位置: ", new_head_pos * cell_size)
		print("食物:")
		print("  - 网格坐标: ", food_pos)
		print("  - 实际位置: ", food.position)
		print("  - 网格计算: ", food.position, " / ", cell_size, " = ", food_pos)
		print("距离差:")
		print("  - 网格差异: ", head_pos - food_pos)
		print("  - 实际位置差异: ", (body[0].position if body.size() > 0 else Vector2.ZERO) - food.position)
		print("  - 碰撞容差: ", collision_tolerance)
		
		# 使用新的碰撞检测方法
		if is_close_enough(new_head_pos * cell_size, food.position):
			print("发生碰撞！蛇吃到食物")
			growing = true
			# 先获取父节点的引用，因为在 queue_free 后可能无法访问
			var main = get_node("/root/Main")
			food.queue_free()
			# 确保食物被删除后再生成新的
			await get_tree().create_timer(0.1).timeout
			if main:
				main.spawn_food()
			# 播放吃食物音效
			eat_sound.play()
			# 更新分数
			var ui = get_node("/root/Main/UILayer/UI")
			if ui:
				ui.update_score(body.size())
	
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
	var ui = get_tree().get_root().get_node("Main/UI")
	if ui:
		ui.show_game_over()
	set_process(false)  # 停止处理输入
