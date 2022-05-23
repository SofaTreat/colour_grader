

//Zoom AA and LUt shader.
if(!surface_exists(lut)) 
{
	lut	= surface_create(512,512); //sLUT;
	surface_set_target(lut);
	shader_set(sh_lut_vfx);
	shader_set_uniform_f(exposure, colour_grading_struct.exposure_level);
	shader_set_uniform_f(contrast, colour_grading_struct.contrast_level);
	shader_set_uniform_f(saturation, colour_grading_struct.saturation_level);
	shader_set_uniform_f_array(lut_color_filter, colour_grading_struct.lut_color_filter_array);
	shader_set_uniform_f_array(lut_vfx_shadows, colour_grading_struct.lut_vfx_shadows_array);
	shader_set_uniform_f_array(lut_vfx_midtones, colour_grading_struct.lut_vfx_midtones_array);
	shader_set_uniform_f_array(lut_vfx_hightlights, colour_grading_struct.lut_vfx_hightlights_array);
	shader_set_uniform_f_array(lut_vfx_SMHranges, colour_grading_struct.lut_vfx_SMHranges_array);
	draw_sprite(sLUT, 0, 0, 0);
	shader_reset();
	surface_reset_target();
}


gpu_set_tex_filter_ext(u_lut_tex, true);
shader_set(sh_lut_draw);
shader_set_uniform_f(u_strength, colour_grading_struct.lut_strength);
texture_set_stage(u_lut_tex, surface_get_texture(lut));
gpu_set_blendenable(false);
draw_surface(application_surface, 0, 0);
gpu_set_blendenable(true);
shader_reset();
gpu_set_tex_filter(true);




//==============================================================================
//==============================================================================