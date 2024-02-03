/// @desc EDIT THE SEED

// Make sure seed surface exists.
if (!surface_exists(seedSurf))
{
	seedSurf = surface_create(seedW, seedH);
}

// Mouse position related to seed. 
// Assmumes it is drawn at x/y position, also rescaled.
var _mouseX = device_mouse_x_to_gui(0);
var _mouseY = device_mouse_y_to_gui(0);
var _x = (_mouseX - x) * seedW / image_xscale;
var _y = (_mouseY - y) * seedH / image_yscale;

// Edit the seed.
surface_set_target(seedSurf);
{
	// Draw on the seed.
	if (device_mouse_check_button(0, mb_left)) 
	{
		if (radius >= 1) 
		{
			draw_circle_color(_x, _y, radius, color, color, false);
		} else {
			draw_point_color(_x, _y, color);
		}
	}

	// Erase from the seed.
	if (device_mouse_check_button(0, mb_right)) 
	{
		gpu_set_blendmode(bm_subtract);
		draw_circle_color(_x, _y, radius + 8, color, color, false);
		gpu_set_blendmode(bm_normal);
	}
}
surface_reset_target();


// Visualize mouse.
draw_circle_color(_mouseX, _mouseY, radius+2, color, color, true);
draw_circle_color(_mouseX, _mouseY, radius, c_black, c_black, true);


















































