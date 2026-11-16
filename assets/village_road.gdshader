shader_type canvas_item;
uniform sampler2D paving : source_color, filter_linear;
uniform float travel = 0.0;
void fragment() {
 vec4 backdrop=texture(TEXTURE,UV);
 float depth=max(0.0,(UV.y-0.27)/0.73);
 float half_width=0.05+max(0.0,UV.y-0.27)*0.90;
 float lateral=abs(UV.x-0.5)/half_width;
 float mask=(1.0-smoothstep(0.80,1.0,lateral))*smoothstep(0.28,0.40,UV.y);
 float x=(UV.x-0.5)/max(0.06,half_width)*0.5+0.5;
 float y=fract(depth*1.7-travel);
 vec4 stone=texture(paving,vec2(0.5+clamp(x,0.0,1.0)*0.5,y*0.5));
 COLOR=vec4(mix(backdrop.rgb,stone.rgb,mask),backdrop.a);
}
