//==========================================================
//
#region DECLARE: SAMPLERS


#define	texA gm_BaseTexture	// Just so it is more condensed,
uniform sampler2D texB;		// and matches name with this.


#endregion
// 
//==========================================================
//
#region DECLARE: UNIFORMS


uniform int uniAction;
uniform vec2 uniSize;
uniform vec2 uniTexel;
uniform float uniThreshold;	
uniform vec2 uniJumpDist;	
uniform float uniJumpMax;	


#endregion
// 
//==========================================================
//
#region DECLARE: FUNCTIONS


vec2 EncodePos(vec2 _pos);
vec2 DecodePos(vec2 _pack);
vec2 EncodeNormal(vec2 _normal);
vec2 DecodeNormal(vec2 _pack);
float EncodeDist(float _dist);
float DecodeDist(float _pack);
vec4 Sample(sampler2D _tex, vec2 _pos);


#endregion
// 
//==========================================================
//
#region DECLARE: ACTIONS


void ActionSeed();
void ActionPass();
void ActionFill();
void ActionField();
void ActionVertex();


#endregion
// 
//==========================================================
//
#region THE MAIN LOOP


void main()
{
		 if (uniAction == 0) ActionSeed();
	else if (uniAction == 1) ActionPass();
	else if (uniAction == 2) ActionFill();
	else if (uniAction == 3) ActionField();
	else if (uniAction == 4) ActionVertex();
}

#endregion
// 
//==========================================================
//
#region DEFINE: ACTIONS


void ActionSeed()
{
	// Look current value.
	vec2 _position = gl_FragCoord.xy;
	vec4 _sample = Sample(texA, _position);
	vec2 _pack = EncodePos(_position);
	
	// Save whether is seed coordinate.
	gl_FragData[0] = (_sample.a >= uniThreshold)
		? vec4(_pack, vec2(0.0))
		: vec4(vec2(0.0), _pack);
}


void ActionPass()
{
	// Preparations
	vec2 _position = gl_FragCoord.xy;
	vec3 _bestMapping = vec3(0.0, 0.0, uniJumpMax);
	vec3 _bestReverse = vec3(0.0, 0.0, uniJumpMax);
	
	// Iterate through 9 values, search closest seed coordinate.
	for(float j = -1.0; j < 2.0; j++) 
	{
		for(float i = -1.0; i < 2.0; i++) 
		{
			vec2 _jump = _position + uniJumpDist * vec2(i, j);
			vec4 _sample = Sample(texA, _jump);
		
			// Check whether has seed coordinate for regular mapping.
			if (length(_sample.xy) > 0.0)
			{
				// Check whether neighbour is closer.
				vec2 _other = DecodePos(_sample.xy);
				float _dist = distance(_position, _other);
				if (_dist < _bestMapping.z) 
				{
					_bestMapping = vec3(_other, _dist);
				}
			}
		
			// Check whether has seed coordinate for regular mapping.
			if (length(_sample.zw) > 0.0)
			{
				// Check whether neighbour is closer.
				vec2 _other = DecodePos(_sample.zw);
				float _dist = distance(_position, _other);
				if (_dist < _bestReverse.z) 
				{
					_bestReverse = vec3(_other, _dist);
				}
			}
		}
	}
	
	// Save the coordinates.
	gl_FragData[0] = vec4(
		EncodePos(_bestMapping.xy),
		EncodePos(_bestReverse.xy)
	);
}


void ActionFill()
{
	// Get coordinate to seed, find the seed value.
	vec2 _current = gl_FragCoord.xy;
	vec4 _sample = Sample(texA, _current);
	vec2 _position = DecodePos(_sample.xy);
	gl_FragData[0] = Sample(texB, _position);
}


void ActionField()
{
	// Get coordinate seed positions.
	vec2 _current = gl_FragCoord.xy;
	vec4 _sample = Sample(texA, _current);
	vec2 _positionA = DecodePos(_sample.xy);
	vec2 _positionB = DecodePos(_sample.zw);
	
	// Calculate signed distance.
	float _distA = distance(_current, _positionA);
	float _distB = distance(_current, _positionB);
	float _dist = _distA - _distB;
	
	// Caluclate normals.
	vec2 _normal = vec2(0.0);
	if (_dist > 0.0) 
	{
		_normal = normalize(_positionA - _current);
	} else if (_dist < 0.0)
	{
		_normal = normalize(_current - _positionB);
	}
	
	// Save the normals and singed distance.
	gl_FragData[0] = vec4(
		EncodeNormal(_normal),
		EncodeDist(_dist),
		1.0
	);
}


void ActionVertex()
{
	// Get four neighbouring positions.
	vec2 _current = gl_FragCoord.xy;
	vec4 _sample00 = Sample(texA, _current + vec2(0.0, 0.0));
	vec4 _sample01 = Sample(texA, _current + vec2(0.0, 1.0));
	vec4 _sample10 = Sample(texA, _current + vec2(1.0, 0.0));
	vec4 _sample11 = Sample(texA, _current + vec2(1.0, 1.0));
	
	// Regular seed coordinate mapping.
	float _regularDifference = 
		 + float((_sample00.xy != _sample01.xy) && (_sample00.xy != _sample10.xy) && (_sample00.xy != _sample11.xy))
		 + float((_sample01.xy != _sample10.xy) && (_sample01.xy != _sample11.xy))
		 + float((_sample10.xy != _sample11.xy));
	
	// Reverse seed coordinate mapping.
	float _reverseDifference = 
		 + float((_sample00.zw != _sample01.zw) && (_sample00.zw != _sample10.zw) && (_sample00.zw != _sample11.zw))
		 + float((_sample01.zw != _sample10.zw) && (_sample01.zw != _sample11.zw))
		 + float((_sample10.zw != _sample11.zw));
	
	// Calculate whether is current position is vertex.
	bool _regularIsVertex = (_regularDifference >= 2.0);
	bool _reverseIsVertex = (_reverseDifference >= 2.0);
	
	// Save the results.
	_reverseIsVertex = false; // Currently not needed, plus output looks better without it.
	gl_FragData[0] = vec4(_regularIsVertex, _reverseIsVertex, 0.5, 1.0);
}



#endregion
// 
//==========================================================
//
#region DEFINE: FUNCTIONS


// Encode/Decode position into normalized value.
vec2 EncodePos(vec2 _pos)
{
	return clamp(floor(_pos), vec2(0.0), uniSize - 1.0) / 255.0;
}


vec2 DecodePos(vec2 _pack)
{
	return _pack * 255.0 + 0.5;
}


// Encode/Decode normal directions into 0-1 range.
vec2 EncodeNormal(vec2 _normal)
{
	return (_normal + 1.0) * 0.5;
}


vec2 DecodeNormal(vec2 _pack)
{
	return _pack * 2.0 - 1.0;
}


// Encode/Decode signed distance.
float EncodeDist(float _dist)
{
	return clamp((_dist + 128.0) / 255.0, 0.0, 1.0);
}


float DecodeDist(float _pack)
{
	return _pack * 255.0 - 128.0;
}


// Sample with given position.
vec4 Sample(sampler2D _tex, vec2 _pos)
{
	return texture2D(_tex, _pos * uniTexel);
}


#endregion
// 
//==========================================================








