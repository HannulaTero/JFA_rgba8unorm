
/// @func	TiteJFA8bit(width, height);
/// @desc	Jump Flood Algorithm, generates coordinate mapping of closest seeds and distance field. 
/// @param	{Real}	_w
/// @param	{Real}	_h
/// @Return	{Struct.TiteJFA}
function TiteJFA8bit(_w=256, _h=256) constructor 
{
//==========================================================
//
#region VARIABLE DECLARATION


	// Variables initialization.
	self.width = 1;
	self.height = 1;
	self.threshold = 0.5;
	self.jumpMax = infinity;
	self.surfaces = {
		temp:	-1,
		coord:	-1,
		fill:	-1,
		field:	-1,
		vertex:	-1
	};
	self.enable = {
		fill:	true,
		field:	true,
		vertex:	false
	};
	
	// Set to wanted shape.
	self.Reshape(_w, _h);


#endregion
// 
//==========================================================
//
#region USER HANDLE METHODS
	
	
	// User handle: Reshape surfaces.
	static Reshape = function(_w=256, _h=256) 
	{
		// Reshape dimensions.
		self.width	= clamp(ceil(_w), 1, 256);
		self.height = clamp(ceil(_h), 1, 256);
		
		// Give warning, if given dimensions were not valid.
		if (self.width != _w) || (self.height != _h)
		{
			var _warning = $"[TiteJFA8bit] Warning: "
				_warning += $"Dimensions [{_w}, {_h}] are not valid, ";
				_warning += $"dimension [{self.width}, {self.height}] used instead.";
			show_debug_message(_warning);
		}
		
		return self;	
	};
	
	
	// User handle: Set jump flood parameters.
	static Params = function(_theshold=0.5, _jumpMax=infinity) 
	{
		self.threshold = _theshold;
		self.jumpMax = _jumpMax;
		return self;
	};
	
	
	// User handle: Which actions are executed when updating.
	static Enable = function(_fill=true, _field=true, _vertex=false) 
	{
		self.enable.fill = _fill;
		self.enable.field = _field;
		self.enable.vertex = _vertex;
		return self;
	};
	
	
	// User handle: Do jump flooding and update all surfaces by given seed.
	static Update = function(_seed) 
	{
		// Get the uniform handles.
		static __shader			= shdTiteJFA8bit;
		static __uniAction		= shader_get_uniform(__shader, "uniAction");
		static __uniSize		= shader_get_uniform(__shader, "uniSize");
		static __uniTexel		= shader_get_uniform(__shader, "uniTexel");
		static __uniThreshold	= shader_get_uniform(__shader, "uniThreshold");
		static __uniJumpDist	= shader_get_uniform(__shader, "uniJumpDist");
		static __uniJumpMax		= shader_get_uniform(__shader, "uniJumpMax");
		static __texB			= shader_get_sampler_index(__shader, "texB");
		
		// Set up gpu state.
		var _previous = shader_current();
		gpu_push_state();
		gpu_set_tex_repeat(false);
		gpu_set_tex_filter(false);
		gpu_set_blendenable(false);
		shader_set(shdTiteJFA8bit);
		
		// Preparations.
		var _w = self.width;
		var _h = self.height;
		self.surfaces.temp = self.Verify(self.surfaces.temp);
		self.surfaces.coord = self.Verify(self.surfaces.coord);
		shader_set_uniform_f(__uniSize, _w, _h);
		shader_set_uniform_f(__uniTexel, 1.0/_w, 1.0/_h);
		shader_set_uniform_f(__uniJumpDist, self.jumpDist);
		shader_set_uniform_f(__uniJumpMax, self.jumpMax);
		
		// Get the seed coordinates into helper surface.
		shader_set_uniform_i(__uniAction, 0);
		shader_set_uniform_f(__uniThreshold, self.threshold);
		surface_set_target(self.surfaces.temp);
		draw_surface_stretched(_seed, 0, 0, _w, _h);
		surface_reset_target();
		
		// Get Coordinate mapping by Jump Flood passes.
		// Ping-pongs between helper and coordinate mapping.
		shader_set_uniform_i(__uniAction, 1);
		var _jumpW = min(_w * 0.5, self.jumpMax);
		var _jumpH = min(_h * 0.5, self.jumpMax);
		var _tempA = self.surfaces.temp;
		var _tempB = self.surfaces.coord;
		var _tempC = self.surfaces.coord;
		shader_set_uniform_f(__uniJumpMax, self.jumpMax);
		while(max(_jumpW, _jumpH) > 1.0) 
		{
			_jumpW = floor(_jumpW * 0.5);
			_jumpH = floor(_jumpH * 0.5);
			shader_set_uniform_f(__uniJumpDist, _jumpW, _jumpH);
			surface_set_target(_tempB);
			draw_surface_stretched(_tempA, 0, 0, _w, _h);
			surface_reset_target();
			_tempC = _tempB;
			_tempB = _tempA;
			_tempA = _tempC;
		}
		
		// Make sure last pass is saved into coordinate mapping.
		if (self.surfaces.coord != _tempC) 
		{
			surface_copy(self.surfaces.coord, 0, 0, _tempC);
		}
		
		// Optional: Generate surface which is filled.
		if (self.enable.fill) 
		{
			self.surfaces.fill = self.Verify(self.surfaces.fill);
			shader_set_uniform_i(__uniAction, 2);
			texture_set_stage(__texB, surface_get_texture(_seed));
			surface_set_target(self.surfaces.fill);
			draw_surface_stretched(self.surfaces.coord, 0, 0, _w, _h);
			surface_reset_target();
		}
		
		// Optional: Generate normal & signed distance field.
		if (self.enable.field)
		{
			self.surfaces.field = self.Verify(self.surfaces.field);
			shader_set_uniform_i(__uniAction, 3);
			surface_set_target(self.surfaces.field);
			draw_surface_stretched(self.surfaces.coord, 0, 0, _w, _h);
			surface_reset_target();
		}
		
		// Optional: Generate vertices.
		if (self.enable.vertex)
		{
			self.surfaces.vertex = self.Verify(self.surfaces.vertex);
			shader_set_uniform_i(__uniAction, 4);
			surface_set_target(self.surfaces.vertex);
			draw_surface_stretched(self.surfaces.coord, 0, 0, _w, _h);
			surface_reset_target();
		}
		
		// Return previous gpu state.
		gpu_pop_state();
		if (_previous != -1) 
			shader_set(_previous);
		else 
			shader_reset();
		return self;
	};
	
	
	// User handle: Verify all surfaces exists and are in correct shape, recreate if not.
	static Verify = function(_surface) 
	{
		// Check whether in correct shape
		if (surface_exists(_surface))
		{
			// Force recreation if wrong.
			if (surface_get_width(_surface) != self.width)
			|| (surface_get_height(_surface) != self.height)
			|| (surface_get_format(_surface) != surface_rgba8unorm)
			{
				surface_free(_surface);
			}
		}
			
		// Recreate missing surface.
		if (!surface_exists(_surface))
		{
			_surface = surface_create(self.width, self.height);
		}
		return _surface;
	};
	
	
	// User handle: Free all surfaces.
	static Free = function() 
	{
		// Iterate through all surfaces.
		struct_foreach(self.surfaces, function(key, element) 
		{
			// Free the surface.
			if (surface_exists(element))
			{
				surface_free(element);
			}
		});
		return self;
	};



#endregion
// 
//==========================================================
}











