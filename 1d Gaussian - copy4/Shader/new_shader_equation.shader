shader_type canvas_item;

uniform vec4 to_color : hint_color;
uniform float threshold_color = 0.94;

void fragment() {
    vec4 curr_color = texture(TEXTURE, UV);

	if (curr_color.x > threshold_color && curr_color.y > threshold_color
	    && curr_color.z > threshold_color){
        COLOR = to_color;
    }else{
        COLOR = vec4(148.0/255.0,216.0/255.0,246.0/255.0,1);
    }
}