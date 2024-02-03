========================================================

JUMP FLOOD ALGORITHM - RGBA8UNORM
	Written for GameMaker Cookbook jam.
	By Tero Hannula
	
========================================================

HOW TO USE

1)	Create struct in Create-event.
		flooder = new TiteJFA8bit(256, 256);

2)	Set optional parameters with Params and Enable.
	Params will set threshold and how far flood can happen.
	Enabled manages, which extra optional information is generated.
		flooder.Params(0.95, 64.0);
		flooder.Enable(true, true, true);

3)	Have surface which acts as seed texture.
	You can draw whatever in seed, thresholded 
	alpha-value determines whether seed or not.
		seed = surface_create(256, 256);	

4)	Call Update in Draw-event and give seed surface.
	Generates coordinate mapping + other enabled information.
		flooder.Update(seed);
		
5)	Now you have generated different mappings from given seed, which can be utilized.
	To draw thick outline, you can use distance from field-surface.
		draw_surface(flooder.surfaces.coord,	0, 0);
		draw_surface(flooder.surfaces.fill,		256, 0);
		draw_surface(flooder.surfaces.field,	512, 0);
		draw_surface(flooder.surfaces.vertex,	768, 0);

6)	Free all surfaces from flooder with Free-method.
		flooder.Free();


========================================================

GENERAL CONSIDERATIONS & INFO

This library is for GameMaker (check gamemaker.io)
 - Made and tested with version: IDE v2023.11.1.129, Runtime v2023.11.1.160. 

Method calls should be done in Draw-events, as this uses shaders for calculations.

Regular coordinate mapping is XY coordinate to closest seed value.
Reverse coordinate mapping is XY coordinate to closest reversed seed value.
Signed distance positive is how far outside the seed, and negative how far inside the seed.

Surfaces use rgba8unorm, so each component is 8 bit value.
 - One pixel encodes two XY coordinates: regular and reverse mapping.
 - Each component can hold value 0 to 255, as they are 8bit value.
 - Shaders read and store 8bit value as normalized into range 0 to 1.
 - Surface maximum size is 256 x 256.
 - Surface minimum size is 1 x 1.
 - This flooder will best work with sizes power of 2.

Surfaces:
 - temp		General helper surface for calculations. This is kept alive to avoid recreating.
 - coord	Coordinate mapping, holds both regular and reverse mapping.
			 - XY: Regular mapping.
			 - ZW: Reverse mapiing.
 - fill		Fills empty areas with seed, which approximates Voronoi Diagram.
 - field	Normal and signed distance field. 
 - vertex	If voronoi diagram would be triangulated, where vertices would be.
 
Setting jumpMax lower can allow you reduce pass counts required.
 
Coordinate mapping does not explicitly store whether it stores seed coordinate or not.
 - Assumes if coordinate is [0, 0] then it is not seed coordinate.
 - This will caue visual artefact, if there are no seeds at all
 - Visual artefact happens too if jump doesn't reach it because too small max jump.

Field has normals and distance field, values are encoded.
 - If used elsewhere, such as other shader, you can for example copy encoding functions.
 - You can make use the fact, that 0.5 is middle value for both.
 - Distance field can actually look better when you downscale it!

Update -method always redoes coordinate mapping with given seed. 
 - There are optional actions: fill, field & vertex
 - These can be toggled by Enable -method.
	
Params -method allow changing threshold value
 - Defines threshold which is considered regular seed, or reverse seed.  

Constructor uses builder pattern.
 - Methods return struct itself.
 - This allows chaining method calls.


========================================================
