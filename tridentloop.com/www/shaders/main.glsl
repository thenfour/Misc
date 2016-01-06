
//uniform sampler2D logoTexture;
//uniform vec2 logoTextureSize;


uniform vec3 iResolution;
uniform float iGlobalTime;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;












// initial inspiration:
// http://static1.squarespace.com/static/53c9cdf3e4b0669c8d19e691/53ffa2f8e4b048b8b84fef6f/53ffa473e4b0f2e23aea116f/1409262727455/MagnetoLayer+2013-06-14-00-13-54-324.gif?format=500w
    
const float bandSpacing = .035;
const float lineSize = 0.01;
const float segmentLength = .3;
const float animSpeed = .5;


float rand(float n){
    return fract(cos(n*89.42)*343.21);
}
float round(float x, float p)
{
    return floor((x+(p*.5))/p)*p;
}
float dtoa(float d)
{
    float aa = 3./length(iResolution.xy);
    return 1.-smoothstep(-aa, aa, d);
}
float sdSegment1D(float uv, float a, float b)
{
	return max(max(a - uv, 0.), uv - b);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy - .5;
    vec2 uvn = uv;
    //uv.x*=iResolution.x/iResolution.y;
    

	if(iResolution.x > iResolution.y)
		uv.x *= iResolution.x / iResolution.y;
	else
		uv.y /= iResolution.x / iResolution.y;


    // warp the hell out of the uv coords
    vec2 oldUV = uv;
    uv = pow(abs(uv), vec2(1.6,1.6))*sign(oldUV);

    float bandRadius = round(length(uv),bandSpacing);
    vec3 bandID = vec3(rand(bandRadius),rand(bandRadius+1.),rand(bandRadius+2.));

    float distToLine = sdSegment1D(length(uv), bandRadius-(lineSize*.5), bandRadius+(lineSize*.5));
    float bandA = dtoa(distToLine);// alpha around this band.
    
    float bandSpeed = .1/max(0.05,bandRadius);// outside = slower
    float r = animSpeed*iGlobalTime+bandID.x *6.28;
    r *= bandSpeed;
    r *= sign(sin(bandID.x*6.28));
    uv *= mat2(cos(r),sin(r),-sin(r),cos(r));

    float angle = mod(atan(uv.x,uv.y),6.28);// angle, animated
    float arcLength = bandRadius * angle;
    
    float color = sign(mod(arcLength, segmentLength*2.)-segmentLength);

    fragColor = vec4(vec3(bandID * color * bandA),1);
    
    //fragColor = vec4(1);
    fragColor = clamp(fragColor, 0., 1.);
    //fragColor *= .4;
    fragColor.rgb = mix(fragColor.rgb, vec3((fragColor.r+fragColor.g+fragColor.b)/3.), .4);
    //fragColor = vec4(.5);
    //fragColor *= pow(length(uvn)*.5,1.);
    fragColor = 1.-fragColor;
    uvn *= .4;
    fragColor *= 1.-dot(uvn,uvn);
    fragColor -= rand(uv.x)*.12;
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



