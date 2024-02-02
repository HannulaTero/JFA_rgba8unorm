/// @desc INITIALIZE

display_set_gui_maximize();


// Create seed.
seedSurf = -1;
seedW = 256;
seedH = 256;


// Create Jump Flooder.
flooder = new TiteJFA8bit();
flooder.Params(0.5, infinity);
flooder.Enable(true, true, true);


// For editing seed.
radius = 0.5;
color = c_white;


// For visualizing.
x = 96;
y = 128;
image_xscale = 256;
image_yscale = 256;

Draw = function(_name, _surface, _i, _j) 
{
	if (!surface_exists(_surface)) return;
	
	// Locals.
	var _w = image_xscale;
	var _h = image_yscale;
	var _b = 48;
	var _wb = _w + _b;
	var _hb = _h + _b;
	var _x = x + _wb * _i;
	var _y = y + _hb * _j;
	var _c = c_black;
	
	// Draw background plate.
	draw_set_alpha(0.75);
	draw_rectangle_color(_x, _y, _x+_w, _y+_h, _c,_c,_c,_c, false);
	draw_set_alpha(1.00);
	
	// Draw surface.
	draw_surface_stretched(_surface, _x, _y, _w, _h);
	
	// Draw outline.
	_c = c_white;
	draw_rectangle_color(_x, _y, _x+_w, _y+_h, _c,_c,_c,_c, true);
	
	// Draw name.
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text(_x + _w * 0.5, _y + _h, _name);
}




