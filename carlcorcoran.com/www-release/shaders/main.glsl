
uniform sampler2D logoTexture;
uniform vec2 logoTextureSize;


uniform vec3 iResolution;
uniform float iGlobalTime;
uniform vec4 iMouse;
uniform vec4 iDate;
uniform float iFFT;








highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
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
	fragColor = vec4(uv.xyyy) * .3;

	uv -= .5;

	if(iResolution.x > iResolution.y)
		uv.x *= iResolution.x / iResolution.y;
	else
		uv.y /= iResolution.x / iResolution.y;

	vec2 uvn = fragCoord.xy / iResolution.xy - .5;

  vec3 logoc = fragColor.rgb;
  float size = 1.;
	blit(logoc, uv, vec2(-size*.5)-vec2(0,-.2), vec2(size), vec3(1));
	fragColor.rgb = logoc;
  
  //fragColor.rgb *= 1.-rand(fragCoord.xy+iGlobalTime)*.3;

  // noise method #2
  float noiseAmt = rand(fragCoord.xy+iGlobalTime);
  fragColor.rgb = mix(fragColor.rgb, 1.-fragColor.rgb, noiseAmt*.17);
  fragColor.rgb = pow(fragColor.rgb, vec3(1./.8));

  //float noiseMix = .15;
  //float noiseAmt = (rand(fragCoord.xy+iGlobalTime)-.5)*noiseMix;
  //fragColor.rgb = clamp(fragColor.rgb, 0., 1.);
  //fragColor.rgb += noiseAmt;

  fragColor.rgb = clamp(fragColor.rgb, 0., 1.);
  fragColor.rgb *= 1.-dot(uvn*1.25, uvn*1.25);

}




void main()
{
	vec4 o = vec4(0);
	mainImage(o, gl_FragCoord.xy);
	o.a = 1.;
	gl_FragColor = o;
}



