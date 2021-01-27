extends Line2D

##########################
#         PARAMS
##########################

# axis parameters
onready var script_parameter = get_node("../Line2D_Axis") 
var x_axis_length
var origin
var x_max_number
var x_scale_width
var y_max_number
var y_scale_width

# drawing
var start_point
var number_points = 100
var step
var canvas_x
var real_x
var probability_Gaussian
var canvas_y
var pre_point

# Gaussian parameters
onready var Gaussian_param = get_node("../..")
var mean = 2.5
var std_deviation = 0.6
var old_mean
var old_deviation

# illustration
var overlapping_margin = 2.5

var mean_vertical_line = Vector2()
var mu_label_adjust = Vector2(0,29)

var sigma_horizontal_line
var sigma_label_adjust = Vector2(0,10)

onready var mu_label = get_node("../Sprite_mu")
onready var sigma_label = get_node("../Sprite_sigma")
#onready var z_label = get_node("../Sprite_z")
#var z_marker_color = Color(0,32.0/255.0,96.0/255.0,1)
var sigma_marker_color = Color(148.0/255.0,216.0/255.0,246.0/255.0,1)
var mu_marker_color = Color(200.0/255.0,239.0/255.0,212.0/255.0,1)

var normalizer
var normalizer_vec = Vector2()
var normalizer_margin = 5
var normalizer_bar_width = 5

# illustration - equation
onready var equation = get_node("../Sprite_equation")
#var dynamic_number_color = Color(239.0/255.0,188.0/255.0,39.0/255.0,1)

############################################

func _ready():
	# update from gesture
	mean = Gaussian_param.mean
	std_deviation = Gaussian_param.std_deviation
	old_mean = mean
	old_deviation = std_deviation

	# drawing parameteres
	origin = script_parameter.origin
	x_scale_width = script_parameter.x_scale_width
	x_max_number = script_parameter.x_max_number
	x_axis_length = script_parameter.x_axis_length.x 
	y_max_number = script_parameter.y_max_number
	y_scale_width = script_parameter.y_scale_width

	# dynamic equation 
	equation.set_global_position(Vector2(400,140))
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font.size = 23	

	if !get_node_or_null("sigma_1"):
		var node = Label.new()
		node.name = "sigma_1"
		add_child(node)	
	get_node("sigma_1").set_global_position(equation.position+\
		Vector2(-70,10))
	get_node("sigma_1").text = str(stepify(std_deviation,0.1))
	get_node("sigma_1").add_color_override("font_color", sigma_marker_color)
	get_node("sigma_1").add_font_override("font",dynamic_font)		

	var dynamic_font_2 = DynamicFont.new()
	dynamic_font_2.font_data = load("res://Fonts/BebasNeue_Bold.ttf")
	dynamic_font_2.size = 18
	
	if !get_node_or_null("sigma_2"):
		var node = Label.new()
		node.name = "sigma_2"
		add_child(node)	
	get_node("sigma_2").set_global_position(equation.position+\
		Vector2(58,-3))
	get_node("sigma_2").text = str(stepify(std_deviation,0.1))
	get_node("sigma_2").add_color_override("font_color", sigma_marker_color)
	get_node("sigma_2").add_font_override("font",dynamic_font_2)			

	if !get_node_or_null("mean_2"):
		var node = Label.new()
		node.name = "mean_2"
		add_child(node)	
	get_node("mean_2").set_global_position(equation.position+\
		Vector2(69,-25))
	get_node("mean_2").text = str(stepify(mean,0.1))
	get_node("mean_2").add_color_override("font_color", mu_marker_color)
	get_node("mean_2").add_font_override("font",dynamic_font_2)


func _process(_delta):
	mean = Gaussian_param.mean
	std_deviation = Gaussian_param.std_deviation
	if mean != old_deviation or std_deviation!=old_deviation:
		update()  # update only when there is a change, lower the program's worload
		old_mean = mean
		old_deviation = std_deviation
		get_node("sigma_1").text = str(stepify(std_deviation,0.1))
		get_node("sigma_2").text = str(stepify(std_deviation,0.1))
		get_node("mean_2").text = str(stepify(mean,0.1))
		
func _draw():
# draw the Gaussian curve
	var max_probability = 1.0/(std_deviation*sqrt(2.0*PI))
	max_probability = 100*max_probability
	number_points = 260  # make the filling color visually good

	start_point = origin - Vector2(x_axis_length,0) # the left side of axis
	step = 2*x_axis_length/(number_points-1)
	pre_point = start_point
	for n in range(1,number_points):
		canvas_x = start_point.x + n*step
		real_x = (canvas_x - origin.x)/ x_scale_width.x
		probability_Gaussian = Gaussian_probability(real_x,mean,std_deviation)
		canvas_y = probability_Gaussian*y_scale_width.y
		
		# draw the curve
		if n!=1:	# avoid margin line
			draw_line(Vector2(canvas_x, start_point.y - canvas_y), pre_point, \
				ColorN("Black"), 1.5, true)				
		pre_point = Vector2(canvas_x, start_point.y - canvas_y)

		# draw the filling color
		var filling_start
		var filling_end
		if origin.y - pre_point.y > 2*overlapping_margin:	
			if max_probability < 35:
				filling_start = Vector2(pre_point.x, pre_point.y+overlapping_margin)
				filling_end = Vector2(pre_point.x, origin.y-overlapping_margin)			
			elif max_probability < 50:	
				if pre_point.x <= mean*x_scale_width.x + origin.x:
					filling_start = Vector2(pre_point.x+1.5, pre_point.y+overlapping_margin)
					filling_end = Vector2(pre_point.x+1.5, origin.y-overlapping_margin)
				else:
					filling_start = Vector2(pre_point.x, pre_point.y+overlapping_margin)					
					filling_end = Vector2(pre_point.x, origin.y-overlapping_margin)
			else:
				if pre_point.x <= mean*x_scale_width.x + origin.x:
					filling_start = Vector2(pre_point.x+2.3, pre_point.y+overlapping_margin)
					filling_end = Vector2(pre_point.x+2.3, origin.y-overlapping_margin)
				else:
					filling_start = Vector2(pre_point.x, pre_point.y+overlapping_margin)					
					filling_end = Vector2(pre_point.x, origin.y-overlapping_margin)
					
			draw_line(filling_start, filling_end, ColorN("Brown"),1.0,true)


# draw the "mean" vertical line
	mean_vertical_line.x = mean*x_scale_width.x + origin.x
	mean_vertical_line.y = origin.y - \
		Gaussian_probability(mean, mean, std_deviation)*y_scale_width.y
	draw_line(Vector2(mean_vertical_line.x, origin.y-overlapping_margin),\
		mean_vertical_line+Vector2(0,overlapping_margin), \
		mu_marker_color, 1.5, true)	

	mu_label.set_global_position(\
		Vector2(mean_vertical_line.x, origin.y)+mu_label_adjust)

# draw the sigma line
	var one_sigma_probability = Gaussian_probability(std_deviation+mean, mean, std_deviation)
	sigma_horizontal_line = origin.y - one_sigma_probability*y_scale_width.y
	var middle_end = mean*x_scale_width.x + origin.x
	var right_end = (mean+std_deviation)*x_scale_width.x + origin.x
	var left_end = (mean-std_deviation)*x_scale_width.x + origin.x
	var peak_prob = Gaussian_probability(mean, mean, std_deviation)
	if (mean >= 0 and right_end < (origin.x + x_axis_length)) or \
		(mean < 0 and left_end-15 < (origin.x - x_axis_length)): # draw right_end
		draw_line(Vector2(middle_end,sigma_horizontal_line),\
			Vector2(right_end-overlapping_margin,sigma_horizontal_line),\
			sigma_marker_color, 1.5, true)
		if peak_prob < 80:
			draw_small_arrow(Vector2(middle_end,sigma_horizontal_line), Vector2(-1,0),\
				sigma_marker_color)
			draw_small_arrow(Vector2(right_end-overlapping_margin,sigma_horizontal_line), \
				Vector2(1,0),sigma_marker_color)		

		sigma_label.set_global_position(\
			Vector2((middle_end+right_end)/2.0, sigma_horizontal_line)+\
			sigma_label_adjust)
		
	else: # draw left_end
		draw_line(Vector2(middle_end,sigma_horizontal_line),\
			Vector2(left_end+overlapping_margin,sigma_horizontal_line),\
			sigma_marker_color, 1.5, true)
		if peak_prob < 80:
			draw_small_arrow(Vector2(middle_end,sigma_horizontal_line), Vector2(1,0),\
				sigma_marker_color)
			draw_small_arrow(Vector2(left_end+overlapping_margin,sigma_horizontal_line), \
				Vector2(-1,0),sigma_marker_color)	

		sigma_label.set_global_position(\
			Vector2((middle_end+left_end)/2.0, sigma_horizontal_line)+\
			sigma_label_adjust)

# draw the normalizer
#	normalizer = 1.0/(std_deviation*sqrt(2*PI))
#	normalizer = normalizer*y_scale_width.y*100
#	normalizer_vec = Vector2(origin.x-normalizer_margin, origin.y-normalizer)
#	draw_line(Vector2(origin.x-normalizer_margin,origin.y-overlapping_margin),\
#		normalizer_vec,z_marker_color,1.5,true)
#	draw_line(Vector2(origin.x-normalizer_margin-normalizer_bar_width, origin.y-normalizer),\
#	Vector2(origin.x-normalizer_margin+normalizer_bar_width, origin.y-normalizer),\
#	z_marker_color,1.5,true)
#	draw_line(Vector2(origin.x-normalizer_margin-normalizer_bar_width, origin.y-overlapping_margin),\
#	Vector2(origin.x-normalizer_margin+normalizer_bar_width, origin.y-overlapping_margin),\
#	z_marker_color,1.5,true)
#
#	if mean < 0 and mean > -0.6:
#		z_label.set_global_position(Vector2(origin.x + 3.0*normalizer_margin,\
#			origin.y - 0.5*normalizer))		
#	else:
#		z_label.set_global_position(Vector2(origin.x - 3.5*normalizer_margin,\
#			origin.y - 0.5*normalizer))

##############################################################################

func Gaussian_probability(x_value, mean_value, deviation):
	var prob = 1.0/(deviation*sqrt(2*PI)) * \
		pow(2.71828,\
		-0.5*(x_value - mean_value)*(x_value - mean_value)/(deviation*deviation)) 
	prob = prob*100 # turn to 100%  
	prob = stepify(prob,0.01)
	return prob	
	
func draw_small_arrow(location, direction, color):
	var b = location + direction.rotated(PI*4.0/5.0)*10
	draw_line(b, location, color, 1.0, true)
	var c = location + direction.rotated(-PI*4.0/5.0)*10
	draw_line(c, location, color, 1.0, true)
