extends Node2D

var Snake = preload("res://scenes/Snake.tscn")
var Food = preload("res://scenes/Food.tscn")
var UI = preload("res://scenes/UI.tscn")

var cell_size = 32  # 每个网格的大小
var grid_size = Vector2(20, 15)  # 游戏区域大小

func _ready():
	randomize()  # 初始化随机数生成器
	
	# 按顺序添加各个节点
	spawn_snake()
	spawn_food()
	spawn_ui()

func spawn_snake():
	var snake_instance = Snake.instantiate()
	$GameArea.add_child(snake_instance)
	snake_instance.name = "Snake"  # 设置固定名称便于查找

func spawn_food():
	print("开始初始化食物：")
	var food_instance = Food.instantiate()
	food_instance.name = "Food"  # 设置固定名称便于查找
	var valid_position = get_random_position()
	$GameArea.add_child(food_instance)  # 添加到游戏区域节点
	food_instance.place_food(valid_position)  # 再设置位置
	print("食物已生成：", food_instance.name, " 位置：", valid_position)

func spawn_ui():
	print("开始初始化UI：")
	var ui_instance = UI.instantiate()
	ui_instance.name = "UI"  # 设置固定名称便于查找
	$UILayer.add_child(ui_instance)  # 添加到UI层
	# 初始化分数
	ui_instance.update_score(0)
	print("UI已生成：", ui_instance.name)

func get_random_position():
	var snake = $GameArea/Snake
	var pos
	var valid = false
	var border_margin = 1  # 边界安全距离
	
	while !valid:
		valid = true
		# 生成位置时避开边界
		pos = Vector2(
			randi() % int(grid_size.x - 2 * border_margin) + border_margin,
			randi() % int(grid_size.y - 2 * border_margin) + border_margin
		)
		
		# 检查是否与蛇重叠（包括头部和身体）
		if snake:
			# 检查蛇头
			var head_pos = snake.body[0].position / cell_size if snake.body.size() > 0 else Vector2(-1, -1)
			if pos == head_pos:
				valid = false
				continue
				
			# 检查蛇身
			for segment in snake.body:
				var segment_pos = segment.position / cell_size
				# 检查是否与蛇身重叠或太近
				if (pos - segment_pos).length() <= 1:  # 如果距离小于等于1个格子，认为太近
					valid = false
					break
	
	print("生成食物位置：", pos, " (避开边界和蛇身)")
	return pos 
