/// @desc MOUSE CONTROL

// Change mouse radis.
if (mouse_wheel_down()) 
{
	radius *= 2;
}

if (mouse_wheel_up()) 
{
	radius /= 2;
}
radius = clamp(radius, 0.5, 32);


// Change mouse color.
var _hue = floor(current_time * 60 / 1000) mod 256;
color = make_color_hsv(_hue, 160, 256);




