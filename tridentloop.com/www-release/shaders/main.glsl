
//uniform sampler2D logoTexture;
//uniform vec2 logoTextureSize;


uniform vec3 iResolution;
uniform float iGlobalTime;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;








const float bandSpacing = .04;
const float lineSize = 0.03;
const float segmentLength = .4;
const float segSpacing = .013;
const float animSpeed = .4;

float rand(float n){
    return fract(cos(n*89.42)*343.21);
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float round(float x, float p)
{
    return floor((x+(p*.5))/p)*p;
}

float dtoa(float d)
{
    float aa = 1.5 / length(iResolution.xy);
    return 1.-smoothstep(-aa, aa, d);
}

float sdSegment1D(float uv, float a, float b)
{
	return max(max(a - uv, 0.), uv - b);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;// - .5;
    uv += 0.2;
	uv *= .6;
    
	if(iResolution.x > iResolution.y)
		uv.x *= iResolution.x / iResolution.y;
	else
		uv.y /= iResolution.x / iResolution.y;

	vec2 oldUV = uv;

    float bandRadius = round(length(uv),bandSpacing);
    vec3 bandID = vec3(rand(bandRadius),rand(bandRadius+1.),rand(bandRadius+2.));

    float distToLine = sdSegment1D(length(uv), bandRadius-(lineSize*.5), bandRadius+(lineSize*.5));
    float bandA = dtoa(distToLine);// alpha to make separation between bands
    
    float bandSpeed = .1/max(0.05,bandRadius);// outside = slower
    float r = animSpeed*iGlobalTime+bandID.x *6.28;
    r *= bandSpeed;
    r *= sign(sin(bandID.x*6.28));
    uv *= mat2(cos(r),sin(r),-sin(r),cos(r));

    float angle = mod(atan(uv.x,uv.y),6.28);// angle, animated
    float arcLength = bandRadius * angle;// more like arc pos

    float distToSeg = sdSegment1D(mod(arcLength, segmentLength), segSpacing*.5, segmentLength - segSpacing*.5);
    float segA = dtoa(distToSeg);// alpha to make separation between bands

    float segN = floor(arcLength / segmentLength) * segmentLength;
    vec3 segID = vec3(rand(segN),rand(segN+1.),rand(segN+2.));// Around the ring
    
    float fill = 1.;
    
    fragColor = vec4(vec3(((segID + bandID / 2.) * fill * bandA * segA)),1);
    
    fragColor = clamp(fragColor, 0., 1.);
    fragColor.rgb = mix(fragColor.rgb, vec3((fragColor.r+fragColor.g+fragColor.b)/3.), .4);
    fragColor.rgb *= 0.4;
    fragColor = 1.-fragColor;

	vec2 uvn = fragCoord.xy / iResolution.xy - .5;
    fragColor *= 1.-dot(uvn,uvn);
    fragColor -= rand(uvn + iGlobalTime)*.12;
    fragColor = clamp(fragColor, 0., 1.);
    fragColor = pow(fragColor, vec4(1./1.4));
    fragColor = clamp(fragColor, 0., 1.);
}















void main()
{
	vec4 o = vec4(0);
	mainImage(o, gl_FragCoord.xy);
	o.a = 1.;
	gl_FragColor = o;
}



