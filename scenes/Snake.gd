extends Node2D

var direction = Vector2.RIGHT
var body = []  # 存储蛇身体的所有部分
var growing = false
var move_timer = 0
var move_delay = 0.2  # 移动间隔时间

func _ready():
    # 初始化蛇的身体
    var head = create_segment(Vector2(5, 5))
    body.append(head)

func create_segment(pos):
    var segment = ColorRect.new()
    segment.size = Vector2(30, 30)  # 稍小于格子大小，留出边框
    segment.position = pos * 32  # 乘以cell_size
    segment.color = Color.GREEN
    add_child(segment)
    return segment

func _process(delta):
    if Input.is_action_just_pressed("ui_up"):
        direction = Vector2.UP
    elif Input.is_action_just_pressed("ui_down"):
        direction = Vector2.DOWN
    elif Input.is_action_just_pressed("ui_left"):
        direction = Vector2.LEFT
    elif Input.is_action_just_pressed("ui_right"):
        direction = Vector2.RIGHT 
    
    move_timer += delta
    if move_timer >= move_delay:
        move_timer = 0
        move()

func move():
    var new_head_pos = body[0].position / 32 + direction
    
    # 检查边界碰撞
    if new_head_pos.x < 0 or new_head_pos.x >= 20 or \
       new_head_pos.y < 0 or new_head_pos.y >= 15:
        game_over()
        return
    
    # 检查食物碰撞
    var food = get_node("/root/Main/Food")
    if food and new_head_pos * 32 == food.position:
        growing = true
        food.queue_free()
        get_parent().spawn_food()
    
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
    get_tree().reload_current_scene() 