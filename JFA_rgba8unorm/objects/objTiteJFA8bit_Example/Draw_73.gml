/// @desc DRAW THE SURFACES

// Draw title.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(16, 16, "Edit with mouse.");
draw_text(16, 32, " - Left/Right to Draw/Erase.");
draw_text(16, 48, " - Mouse wheel to change size.");

// Draw surfaces.
var _surfaces = flooder.surfaces;
Draw("Seed",	seedSurf, 0, 0);
Draw("Coord",	_surfaces.coord, 1, 0);
Draw("Fill",	_surfaces.fill, 0, 1);
Draw("Field",	_surfaces.field, 1, 1);
Draw("Vertex",	_surfaces.vertex, 2, 1);

// Draw example.
var _shader = shdTiteJFA8bit_ExampleOutline;
var _uniTime = shader_get_uniform(_shader, "uniTime");
var _texField = shader_get_sampler_index(_shader, "texField");
var _texture = surface_get_texture(flooder.surfaces.field);
shader_set(_shader);
shader_set_uniform_f(_uniTime, current_time / 1000.0);
texture_set_stage(_texField, _texture);
draw_surface_stretched(flooder.surfaces.fill, room_width - 320, 32.0, 256, 256);
shader_reset();