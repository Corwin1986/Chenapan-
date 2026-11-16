shader_type canvas_item;
render_mode unshaded;
varying vec2 projected_uv;
varying float reciprocal_depth;
void vertex() {
	reciprocal_depth = abs(VERTEX.x - 360.0) / (190.0 * 1.53);
	projected_uv = UV * reciprocal_depth;
}
void fragment() {
	COLOR = texture(TEXTURE, projected_uv / reciprocal_depth);
}
