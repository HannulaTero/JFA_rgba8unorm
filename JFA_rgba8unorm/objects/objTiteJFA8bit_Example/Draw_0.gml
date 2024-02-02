/// @desc DO THE FLOOD PASS

// Make sure seed surface exists.
if (!surface_exists(seedSurf))
{
	seedSurf = surface_create(seedW, seedH);
}

// Do the flooding.
flooder.Update(seedSurf);




