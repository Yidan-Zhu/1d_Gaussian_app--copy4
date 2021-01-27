extends Node

############################
#        PARAMS
############################
# axis parameters
onready var script_parameter = get_node("CanvasLayer/Line2D_Axis") 
var origin
var x_scale_width
var y_scale_width
var input_y_not_too_small = 25

export var mean = 2.5
export var std_deviation = 0.6
var peak_location
var peak_probability

# instruction finished
onready var instruction_node = get_node("CanvasLayer_start_instruction/Line2D_instruction")
var instruction_finished = false

# two-finger change std_deviation
var events = {}
var position10
var position20
var gesture_sigma_ratio = 0.5

####################################################################

func _ready():
	origin = script_parameter.origin
	x_scale_width = script_parameter.x_scale_width
	y_scale_width = script_parameter.y_scale_width	
	instruction_finished = instruction_node.animation_finish	

func _process(delta):
	instruction_finished = instruction_node.animation_finish

func _input(event):
# take the most recent two finger-touch inputs
	if event is InputEventScreenTouch:
		if event.pressed:
			events[event.index] = event
		else:
			events.erase(event.index)
			
# input gestures
	var drag_region_x_min = script_parameter.origin.x - \
		script_parameter.x_scale_width.x*script_parameter.x_max_number
	var drag_region_x_max = script_parameter.origin.x + \
		script_parameter.x_scale_width.x*script_parameter.x_max_number
	var drag_region_y_min = script_parameter.origin.y - \
		script_parameter.y_scale_width.y*(script_parameter.y_max_number+25)
	var drag_region_y_max = script_parameter.origin.y	

	if event.position.x > drag_region_x_min and \
		event.position.x < drag_region_x_max and \
		event.position.y < drag_region_y_max-input_y_not_too_small and \
		event.position.y > drag_region_y_min and instruction_finished:
		# one-input changes peak
		if event is InputEventScreenDrag or \
			(event is InputEventScreenTouch and event.is_pressed()):
			events[event.index] = event
			if events.size() == 1:
				peak_location = event.position
				mean = (peak_location.x - origin.x)/x_scale_width.x
				peak_probability = (origin.y - peak_location.y)/y_scale_width.y
				std_deviation = reverse_calculate_std_deviation(peak_probability)
		# two-input changes sigma
			elif events.size() == 2:	
				position10 = events[0].position
				position20 = events[1].position
				if abs(position10.y - position20.y) < 100: # if in horizontal line
					if gesture_sigma_ratio*0.5*abs(position10.x - position20.x)/x_scale_width.x <= 2.49 and \
						gesture_sigma_ratio*0.5*abs(position10.x - position20.x)/x_scale_width.x >= 0.4:
						std_deviation = gesture_sigma_ratio*0.5*abs(position10.x - position20.x)/x_scale_width.x
					elif gesture_sigma_ratio*0.5*abs(position10.x - position20.x)/x_scale_width.x > 2.49:
						std_deviation = 2.49
					else:
						std_deviation = 0.4

#########################################################################
# calculate sigma from probability at mean
func reverse_calculate_std_deviation(mean_probability):
	mean_probability = mean_probability/100.0
	var deviation = 1.0/mean_probability
	deviation = deviation/sqrt(2.0*PI)
	return stepify(deviation,0.01)
	
