extends Line2D

####################
#      PARAMS
####################

# control params
export var animation_finish = false
onready var script_parameter_axes = get_node("../../CanvasLayer/Line2D_Axis")
onready var param_initial_G = get_node("../..")
var animation_count = 0

# instruction parameters
var x_limit
var y_limit
var origin
var initial_mean
var initial_sigma

var initial_peak = Vector2()
var illustration_region_color=Color(63.0/255.0,73.0/255.0,221.0/255.0,0.45)
var illustration_peak
var path_color = Color(246.0/255.0,89.0/255.0,26.0/255.0,1)

# discrete axis variables
var x_scale_width = 47
var x_max_number = 6
var x_positive_error_points = 6 
var y_scale_width = 2.5

#######################################
func _ready():
	x_limit = script_parameter_axes.x_scale_width.x * script_parameter_axes.x_max_number
	y_limit = 120*y_scale_width # slighter shorter than the y axis length
	origin = script_parameter_axes.origin
	initial_mean = param_initial_G.mean
	initial_sigma = param_initial_G.std_deviation
	
	initial_peak.x = origin.x+ initial_mean*x_scale_width
	initial_peak.y = origin.y - y_scale_width*Gaussian_probability(\
		initial_mean, initial_mean, initial_sigma)
	illustration_peak = origin + Vector2(-3*x_scale_width,-80*y_scale_width)

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			animation_count += 1
			update()

func _draw():
	if animation_count <=1:
		# add a button to skip animation
		if !get_node_or_null("button"):
			var node_button = Button.new()
			node_button.name = "button"
			add_child(node_button)		
		get_node("button").set_global_position(Vector2(110,170))
		get_node("button").text = "Skip Instruction"
		if (get_node("button").is_pressed()):
			animation_count = 2
			get_node("button").queue_free()
			# delete
			if get_node_or_null("Instruction_one"):
				get_node("Instruction_one").queue_free()
				get_node("example_sprite1").queue_free()	
			if get_node_or_null("Instruction_two"):
				get_node("Instruction_two").queue_free()
				get_node("example_sprite2").queue_free()

		# illustration part
		if animation_count == 0:
			# draw a region 
			draw_rect(Rect2(origin.x - x_limit, \
				origin.y - y_limit, 2.0*x_limit, \
				110*2.5), illustration_region_color,true,1.0,true)
	
			# draw a path
			draw_circle(illustration_peak,4.0,ColorN("Black"))
			draw_circle(initial_peak,5.0,path_color)
			draw_line(initial_peak+Vector2(-10,-2), \
				illustration_peak+Vector2(20,4),path_color,2.0,true)
			draw_triangle(illustration_peak+Vector2(20,4), \
				illustration_peak-initial_peak+Vector2(30,6), 7.0,path_color)
	
			if !get_node_or_null("example_sprite1"):
				var node2 = Sprite.new()
				node2.name = "example_sprite1"
				add_child(node2)
			get_node("example_sprite1").set_global_position(\
				initial_peak+Vector2(-50,-50))
			get_node("example_sprite1").texture = load("res://Sprites/finger_swipe.png")
			get_node("example_sprite1").rotation_degrees = 180
			get_node("example_sprite1").set_scale(Vector2(0.35,0.35))
	
			var dynamic_font = DynamicFont.new()
			dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
			dynamic_font.size = 19
			
			if !get_node_or_null("Instruction_one"):
				var node = Label.new()
				node.name = "Instruction_one"
				add_child(node)	
			get_node("Instruction_one").set_global_position(\
				illustration_peak+Vector2(-115,-60))
			get_node("Instruction_one").text = \
				"Drag/Touch in the region to \nchange the peak of Gaussian"
			get_node("Instruction_one").add_color_override("font_color", path_color)	
			get_node("Instruction_one").add_font_override("font",dynamic_font)
	
			# draw a new Gaussian
			var deviation = reverse_calculate_std_deviation(80)
			var mean = -3 
	
			var max_probability = 1.0/(deviation*sqrt(2.0*PI))
			max_probability = 100*max_probability
			var number_points = 260
		
			var start_point = origin - Vector2(x_scale_width,0)*x_max_number # the left side of axis
			var step = 2*x_limit/(number_points-1)
			var pre_point = start_point
			var canvas_x
			var real_x
			var probability_Gaussian
			var canvas_y
			for n in range(1,number_points-x_positive_error_points):
				canvas_x = start_point.x + n*step
				real_x = (canvas_x - origin.x)/ x_scale_width
				probability_Gaussian = Gaussian_probability(real_x,mean,deviation)
				canvas_y = probability_Gaussian*y_scale_width
				
				# draw the curve
				if n!=1:	# avoid margin line
					draw_line(Vector2(canvas_x, start_point.y - canvas_y), pre_point, \
						ColorN("Black"), 1.5, true)				
				pre_point = Vector2(canvas_x, start_point.y - canvas_y)
		
		elif animation_count == 1:
			# two_finger change std_deviation
			if get_node_or_null("Instruction_one"):
				get_node("Instruction_one").queue_free()
				get_node("example_sprite1").queue_free()
				
			# draw a region 
			draw_rect(Rect2(origin.x - x_limit, \
				origin.y - y_limit, 2.0*x_limit, \
				110*2.5), illustration_region_color,true,1.0,true)		
			
			# draw a pinch
			
			var pinch_center = Vector2()
			pinch_center.x = initial_peak.x
			pinch_center.y = origin.y - y_scale_width*0.5*\
				Gaussian_probability(initial_mean, initial_mean, \
				initial_sigma)
			
			if !get_node_or_null("example_sprite2"):
				var node3 = Sprite.new()
				node3.name = "example_sprite2"
				add_child(node3)
			get_node("example_sprite2").set_global_position(pinch_center)
			get_node("example_sprite2").texture = load("res://Sprites/finger_pinch.png")
			get_node("example_sprite2").rotation_degrees = 40
			get_node("example_sprite2").set_scale(Vector2(0.15,0.15))	
		
			if !get_node_or_null("Instruction_two"):
				var node4 = Label.new()
				node4.name = "Instruction_two"
				add_child(node4)	
			get_node("Instruction_two").set_global_position(pinch_center+\
				Vector2(-90,-140))
			get_node("Instruction_two").text = \
				"Two-finger pinch to change \nthe std-deviation of Gaussian"
	
			var dynamic_font = DynamicFont.new()
			dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
			dynamic_font.size = 19
			
			get_node("Instruction_two").add_color_override("font_color", path_color)	
			get_node("Instruction_two").add_font_override("font",dynamic_font)
	
	else:
		if get_node_or_null("Instruction_two"):
			get_node("Instruction_two").queue_free()
			get_node("example_sprite2").queue_free()
			get_node("button").queue_free()
		animation_finish = true

######################################################

func Gaussian_probability(x_value, mean_value, deviation):
	var prob = 1.0/(deviation*sqrt(2*PI)) * \
		pow(2.71828,\
		-0.5*(x_value - mean_value)*(x_value - mean_value)/(deviation*deviation)) 
	prob = prob*100 # turn to 100%  
	prob = stepify(prob,0.01)
	return prob	

func draw_triangle(pos, dir, size, color):
	dir = dir.normalized()
	var a = pos + dir*size
	var b = pos + dir.rotated(2*PI/3)*size
	var c = pos + dir.rotated(4*PI/3)*size
	var points = PoolVector2Array([a,b,c])
	draw_polygon(points, PoolColorArray([color]))

func reverse_calculate_std_deviation(mean_probability):
	mean_probability = mean_probability/100.0
	var deviation = 1.0/mean_probability
	deviation = deviation/sqrt(2.0*PI)
	return stepify(deviation,0.01)
