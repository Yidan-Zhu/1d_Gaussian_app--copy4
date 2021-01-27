extends Line2D

######################################
#            PARAM
######################################
# axes
export var origin = Vector2(400,500)
export var x_axis_length = Vector2(300,0)
export var y_axis_length = Vector2(0,260)
# axis labels
var x_label_adjust = Vector2(0,10)
var y_label_adjust = Vector2(20,5)
var y_tick_label_adjust = Vector2(-30,-6)
# ticks
var x_scale_length = Vector2(0,-5)
var y_scale_length = Vector2(5,0) 
export var x_max_number = 6
export var y_max_number = 100
# scale info
export var x_scale_width = Vector2(47,0)   # x : 47 pixel = 1
export var y_scale_width = Vector2(0,2.5)   # y : 2.5 pixel = 1%

# equation static drawing
var color_title = Color(0,32.0/255.0,96.0/255.0,1)
onready var equation = get_node("../Sprite_equation")
#onready var mu2 = get_node("../Sprite_mu2")
#onready var sigma2 = get_node("../Sprite_sigma2")
var symbol_arrow_color = Color(163.0/255.0,73.0/255.0,164.0/255.0,1)

#######################################

func _ready():
# add a title
	if !get_node_or_null("title"):
		var node = Label.new()
		node.name = "title"
		add_child(node)	
	get_node("title").set_global_position(Vector2(100,70))
	get_node("title").text = "1D Gaussian Probability Density"
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 25

	get_node("title").add_color_override("font_color", color_title)
	get_node("title").add_font_override("font",dynamic_font)	

## add symbol and arrow to equation
#	mu2.set_global_position(equation.position+Vector2(120,-60))
#	sigma2.set_global_position(equation.position+Vector2(40,50))	

	
func _draw():
# draw symbol and arrow
#	var start_point_1 = sigma2.position + Vector2(-15,2)
#	var end_point_1 = equation.position + Vector2(-50,40)
#	draw_line(start_point_1, end_point_1, symbol_arrow_color,1.5,true)
#	draw_small_arrow(end_point_1, end_point_1-start_point_1,symbol_arrow_color)	
#
#	var start_point_2 = sigma2.position + Vector2(4,-10)
#	var end_point_2 = equation.position+Vector2(55.5,15)
#	draw_line(start_point_2, end_point_2, symbol_arrow_color,1.5,true)
#	draw_small_arrow(end_point_2, end_point_2-start_point_2,symbol_arrow_color)	
#
#	var start_point_3 = mu2.position + Vector2(-10,10)
#	var end_point_3 = equation.position+Vector2(82,-30)
#	draw_line(start_point_3, end_point_3, symbol_arrow_color,1.5,true)
#	draw_small_arrow(end_point_3, end_point_3-start_point_3,symbol_arrow_color)	
	
# draw axis lines and arrows
	draw_line(origin, origin+x_axis_length,ColorN("Black"),1.0, true)
	draw_line(origin, origin-x_axis_length,ColorN("Black"),1.0, true)
	draw_line(origin, origin-y_axis_length,ColorN("Black"),1.0, true)

	draw_triangle(origin+x_axis_length, Vector2(1,0),5)
	draw_triangle(origin-x_axis_length, Vector2(-1,0),5)
	draw_triangle(origin-y_axis_length, Vector2(0,-1),5)

# set axes text
	var x_axis_text = get_node("../Label_x_axis")
	x_axis_text.set_global_position(origin+x_axis_length + x_label_adjust)
	var y_axis_text = get_node("../Label_y_axis")
	y_axis_text.set_global_position(origin-y_axis_length - 1.5*y_label_adjust - x_label_adjust)

# draw axis ticks
	for n in range(x_max_number):
		draw_line(origin+(n+1)*x_scale_width,\
			origin+(n+1)*x_scale_width-x_scale_length, \
			ColorN("Black"),1.0, true)
		draw_line(origin-(n+1)*x_scale_width,origin-(n+1)*x_scale_width-x_scale_length, \
			ColorN("Black"),1.0, true)

	for n in range(25, y_max_number+1, 25):
		var y_tick = Vector2(origin.x, origin.y - n*y_scale_width.y)
		draw_line(y_tick, y_tick - y_scale_length, ColorN("Black"),1.0, true)

# add tick text
	if !get_node_or_null("../Label_(" + str(0)):
		var node = Label.new()
		node.name = "Label_(" + str(0)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(0)).set_global_position(\
		origin + x_label_adjust)
	get_node("../Label_(" + str(0)).text = str(0)

	if !get_node_or_null("../Label_(" + str(x_max_number)):
		var node = Label.new()
		node.name = "Label_(" + str(x_max_number)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(x_max_number)).set_global_position(\
		origin+x_max_number*x_scale_width + x_label_adjust)
	get_node("../Label_(" + str(x_max_number)).text = str(x_max_number)
		
	if !get_node_or_null("../Label_(" + str(-x_max_number)):
		var node = Label.new()
		node.name = "Label_(" + str(-x_max_number)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(-x_max_number)).set_global_position(\
		origin+(-x_max_number)*x_scale_width + x_label_adjust)
	get_node("../Label_(" + str(-x_max_number)).text = str(-x_max_number)

	if !get_node_or_null("../Label_(" + str(y_max_number)):
		var node = Label.new()
		node.name = "Label_(" + str(y_max_number)
		get_parent().add_child(node)	
	get_node("../Label_(" + str(y_max_number)).set_global_position(\
		origin-(y_max_number/2.0)*y_scale_width + y_tick_label_adjust)
	get_node("../Label_(" + str(y_max_number)).text = str(0.5)
		
################################################################################
# define a triangle arrow drawing function
func draw_triangle(pos, dir, size):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([Color(0,0,0)]))

func draw_small_arrow(location, direction, color):
	direction = direction.normalized()
	var b = location + direction.rotated(PI*4.0/5.0)*10
	draw_line(b, location, color, 1.0, true)
	var c = location + direction.rotated(-PI*4.0/5.0)*10
	draw_line(c, location, color, 1.0, true)
