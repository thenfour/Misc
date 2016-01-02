
uniform sampler2D logoTexture;
uniform vec2 logoTextureSize;


uniform vec3 iResolution;
uniform float iGlobalTime;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;









// initial inspiration:
// http://static1.squarespace.com/static/53c9cdf3e4b0669c8d19e691/53ffa2f8e4b048b8b84fef6f/53ffa473e4b0f2e23aea116f/1409262727455/MagnetoLayer+2013-06-14-00-13-54-324.gif?format=500w
    
const float bandSpacing = .07;
const float lineSize = bandSpacing * .8;
const float segmentLength = .7;
const float animSpeed = .3;


highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

float rand(float n){
    return fract(cos(n*89.42)*343.42);
}
float round(float x, float p)
{
    return floor((x+(p*.5))/p)*p;
}
float dtoa(float d, float amount)
{
    return 1.-smoothstep(-.002,.002,d);
    //return clamp(1./(clamp(d,1./amount,1.)*amount),0.,1.);
}
// signed distance to segment of 1D space. like, for making a vertical column
float sdSegment1D(float uv, float a, float b)
{
    return max(a - uv, uv - b);
}
float sdAxisAlignedRect(vec2 uv, vec2 tl, vec2 br)
{
  	vec2 d = max(tl - uv, uv - br);
    return length(max(vec2(0), d)) + min(0., max(d.x, d.y));
}



void blit(inout vec3 o, vec2 uv, vec2 pos, vec2 destSize, vec3 color)
{
    uv -= pos;
    uv /= destSize;
    float d = sdAxisAlignedRect(uv, vec2(0.), vec2(1.));
    float alpha = step(d, 0.);
    vec4 s = texture2D(logoTexture, uv);
    o = mix(o.rgb, color, s.a * alpha);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
		vec4 bg = vec4(uv.xyyy) * .3;
    uv += vec2(-.5,-.7);
    //uv.y -=1.;
    //uv *= .3;
//    float distToEdge = -sdAxisAlignedRect(uv, vec2(-.5), vec2(.5)) /.5;

	if(iResolution.x > iResolution.y)
		uv.x *= iResolution.x / iResolution.y;
	else
		uv.y /= iResolution.x / iResolution.y;


    vec2 uvLogo = uv;
    

      vec3 logoMatte = vec3(.2,.05,.2);
      logoMatte = vec3(1);
  fragColor = bg;// * vec4(vec3(logoMatte * color * bandA),1) * att;
//    fragColor = logoMatte * (fragColor.)
		{
			vec2 uvn = fragCoord.xy / iResolution.xy - .5;
			vec2 uvPix = fragCoord.xy;

	    vec3 logoc = fragColor.rgb;
	    float size = 1.;
			blit(logoc, uvLogo, vec2(-size*.5)-vec2(0), vec2(size), logoMatte);
			fragColor.rgb = logoc;
		  fragColor.rgb *= 1.-rand(uvPix+iGlobalTime)*.3;
		  fragColor.rgb *= 1.-dot(uvn, uvn);
		}



    //vec4 logo = texture2D(logoTexture, fragCoord.xy / iResolution.xy);
    //fragColor = mix(fragColor, logo, logo.a);
    //fragColor = vec4(distToEdge);
}















void main()
{
	vec4 o = vec4(0);
	mainImage(o, gl_FragCoord.xy);
	o.a = 1.;
	gl_FragColor = o;
}



