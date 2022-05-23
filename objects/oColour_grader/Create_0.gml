// BASIC DOCUMENTATION

// oColour_grader needs ImGuiGML to work. If you don't have it already and its not included in this package, you can find it for free online :)
// Rousr makes ImGuiGML.

// How to use!

// Drag oColour_grader into your room in the room editor.
// press F1 to access the editing box.

// Use change_lut_setup(_setup)
// to switch colour grading setups at any point, it accepts both the name of the setup as a string, or its position in the colour_grading_array.

// Directories!
// by default oColour_grader saves its data to the working_directory, I can't guarantee  the datas safety there so I would make backups. 
// You can find your colour_grading.data file in user -> appData -> local -> project name folder.
// but if you want to save and load that file to and from the project directory, (ie to keep everything in a git repo)
// there is a file called "pre_run_step.bat" in the datafiles, move that into the project root folder to be able to save data into the project file.
// for this to work you need to turn off file sandboxing in the windows options of your project.
// This also only works for windows.

// Shout outs to Rousr for ImGuiGml, Juju for Directory pathing and Gaming Reverend for the original lut shader.  

//==============================================================================
  
if (file_exists(working_directory + "projectDirectoryPath"))
{
	var _buffer = buffer_load(working_directory + "projectDirectoryPath");
	file_directory = buffer_read(_buffer, buffer_text);
	buffer_delete(_buffer);

	//Trim off any invalid characters at the end of the project directory string
	var _i = string_length(file_directory);
	repeat(_i)
	{
	    if (ord(string_char_at(file_directory, _i)) >= 32) break;
	    --_i;
	}           
	file_directory = string_copy(file_directory, 1, _i) + "colour_grading_files\\";
} 
else
{
	file_directory = working_directory + "colour_grading_files\\";
}



//==============================================================================
//shader variables.
lut = -1;
lut_img     = -1;
use_lut_img = false;

u_strength	= shader_get_uniform(sh_lut_draw, "strength");
lut_strength = 1;
u_lut_tex	= shader_get_sampler_index(sh_lut_draw, "lut_tex");


//sh_lut_vfx
exposure	= shader_get_uniform(sh_lut_vfx, "exposure");
exposure_level = 0;
contrast	= shader_get_uniform(sh_lut_vfx, "contrast");
contrast_level = 1;
saturation	= shader_get_uniform(sh_lut_vfx, "saturation");
saturation_level = 1;

lut_color_filter = shader_get_uniform(sh_lut_vfx, "color_filter");
lut_color_filter_array = [1,1,1];

lut_vfx_shadows	= shader_get_uniform(sh_lut_vfx, "shadows");

lut_vfx_shadows_array = [1,1,1];

lut_vfx_midtones	= shader_get_uniform(sh_lut_vfx, "midtones");
lut_vfx_midtones_array = [1,1,1];

lut_vfx_hightlights	= shader_get_uniform(sh_lut_vfx, "highlights");
lut_vfx_hightlights_array = [1,1,1];

lut_vfx_SMHranges	= shader_get_uniform(sh_lut_vfx, "SMHranges");
lut_vfx_SMHranges_array = [0, 0.3, 0.55, 1];

//==============================================================================
//==============================================================================
//functions
create_default_grading_struct = function()
{
	var _struct =
	{
		name                        : "default_" + string(colour_grading_struct_selected),
		use_lut_img                 : false,
		lut_img                     : 0,
		lut_img_array_index         : 0,
		lut_strength                : 1,  
		exposure_level              : 2,        
		contrast_level              : 1,          
		saturation_level            : 1,       
		lut_color_filter_array      : [1,1,1],       
		lut_vfx_shadows_array       : [1,1,1],    
		lut_vfx_midtones_array      : [1,1,1],       
		lut_vfx_hightlights_array   : [1,1,1],    
		lut_vfx_SMHranges_array     : [0, 0.3, 0.55, 1],
	}
	return _struct;
}

//==============================================================================

change_lut_setup = function(_setup)
{
	if(is_string(_setup))
	{
		for( var _i = 0; _i < array_length(colour_grading_array); _i++)
		{
			if (_setup == colour_grading_array[_i].name)
			{
				colour_grading_struct_selected = _i;
				colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
				setup_lut_vfx();
				return;
			}
		}
		
		show_debug_message("oColour_grading : unrecognised name, setting to first lut setup.");
		colour_grading_struct_selected = 0;
		colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
		setup_lut_vfx();
		return;
	}
	else
	{	
		if (colour_grading_struct_selected >= array_length(colour_grading_array))
		or (colour_grading_struct_selected < 0)
		{
			show_debug_message("oColour_grading : value out of array range, setting to 0");
			colour_grading_struct_selected = 0;
		}
		colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
		setup_lut_vfx();
	}
}

//==============================================================================

setup_lut_vfx = function()
{
	if(surface_exists(lut))
	{
		surface_free(lut);
	}
}

//==============================================================================

randomize_screen_vfx = function()
{
	colour_grading_struct.lut_strength =  random(1);
	colour_grading_struct.exposure_level = random(2);
	colour_grading_struct.contrast_level = random(5);
	colour_grading_struct.saturation_level = random(5);
	colour_grading_struct.lut_color_filter_array = [random(1), random(1), random(1)];
	colour_grading_struct.lut_vfx_shadows_array = [random(3), random(3), random(3)];
	colour_grading_struct.lut_vfx_midtones_array = [random(3), random(3), random(3)];
	colour_grading_struct.lut_vfx_hightlights_array = [random(3), random(3), random(3)];
	//colour_grading_struct.lut_vfx_SMHranges_array = [random(1),random(1),random(1),random(1)];

	setup_lut_vfx();
}

//==============================================================================

colour_grading_save_file = function(_file_directory, _array)
{
	var _string = json_stringify(_array);
	var _buffer = buffer_create(string_byte_length(_string) +1, buffer_fixed, 1);
	buffer_write(_buffer, buffer_string, _string);
	buffer_save(_buffer, _file_directory + "colour_grading.data");
	buffer_delete(_buffer);
}

//==============================================================================

colour_grading_load_file = function(_file_directory)
{
	var _file = _file_directory + "colour_grading.data";
	if (file_exists(_file))
	{
		var _buffer = buffer_load(_file);
		var _string = buffer_read( _buffer, buffer_string);
		buffer_delete(_buffer);
		colour_grading_array = json_parse(_string);
		
		if (colour_grading_struct_selected >= array_length(colour_grading_array))
		or (colour_grading_struct_selected < 0)
		{
			colour_grading_struct_selected = 0;
		}
		colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
		setup_lut_vfx();

	}
	else
	{
		colour_grading_array[0] = create_default_grading_struct();
		colour_grading_struct_selected = 0;
		colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
		setup_lut_vfx();
	}
}


//==============================================================================
//==============================================================================
//setup.

colour_grading_load_file(file_directory);
window_settings_active = false;
