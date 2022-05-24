
function __colour_grader_init()
{
	var _filters = __colour_grader_load_file();
	
	var _colour_grader = 
	{
		lut_tex				 : shader_get_sampler_index(sh_lut_draw, "lut_tex"),
		lut_strength		 : shader_get_uniform(sh_lut_draw, "strength"),
		strength      		 : shader_get_uniform(sh_colour_grader, "strength"),
		exposure      		 : shader_get_uniform(sh_colour_grader, "exposure"),
		contrast        	 : shader_get_uniform(sh_colour_grader, "contrast"),
		saturation      	 : shader_get_uniform(sh_colour_grader, "saturation"),
		lut_color_filter	 : shader_get_uniform(sh_colour_grader, "color_filter"),
		lut_vfx_shadows		 : shader_get_uniform(sh_colour_grader, "shadows"),
		lut_vfx_midtones	 : shader_get_uniform(sh_colour_grader, "midtones"),
		lut_vfx_hightlights	 : shader_get_uniform(sh_colour_grader, "highlights"),
		lut_vfx_SMHranges	 : shader_get_uniform(sh_colour_grader, "SMHranges"),
		filters              : _filters,
		selected_filter      : "",
		editing              : false,
	}
	
	global.__colour_grader_data_struct = _colour_grader;
	global.__colour_grader_lut_surface = -1;
}

//==============================================================================

function __colour_grader_load_file()
{
	var _file_directory;
	
	if (file_exists(working_directory + "projectDirectoryPath"))
	{
		var _buffer = buffer_load(working_directory + "projectDirectoryPath");
		_file_directory = buffer_read(_buffer, buffer_text);
		buffer_delete(_buffer);
		//Trim off any invalid characters at the end of the project directory string
		var _i = string_length(_file_directory);
		repeat(_i)
		{
		    if (ord(string_char_at(_file_directory, _i)) >= 32) break;
		    --_i;
		}           
		_file_directory = string_copy(_file_directory, 1, _i) + "colour_grading_files\\";
	} 
	else
	{
		_file_directory = working_directory + "colour_grading_files\\";
	}
	
	
	var _file = _file_directory + "colour_grading.data";
	if (file_exists(_file))
	{
		//need to check for NULL or an empty file here.
		var _buffer = buffer_load(_file);
		var _string = buffer_read( _buffer, buffer_string);
		buffer_delete(_buffer);
		var _filters = json_parse(_string);
	}
	else
	{
		var _filters = 
		{
			first_filter : __colour_grader_create_default_filter("first_filter"),
		}

	}
	/*
			var _filters = 
		{
			first_filter : __colour_grader_create_default_filter("first_filter"),
		}*/
	
	return _filters;
}


function __colour_grader_save_file()
{
	var _file_directory;
	
	if (file_exists(working_directory + "projectDirectoryPath"))
	{
		var _buffer = buffer_load(working_directory + "projectDirectoryPath");
		_file_directory = buffer_read(_buffer, buffer_text);
		buffer_delete(_buffer);
		//Trim off any invalid characters at the end of the project directory string
		var _i = string_length(_file_directory);
		repeat(_i)
		{
		    if (ord(string_char_at(_file_directory, _i)) >= 32) break;
		    --_i;
		}           
		_file_directory = string_copy(_file_directory, 1, _i) + "colour_grading_files\\";
	} 
	else
	{
		_file_directory = working_directory + "colour_grading_files\\";
	}
	
	var _string = json_stringify(global.__colour_grader_data_struct.filters);
	var _buffer = buffer_create(string_byte_length(_string) +1, buffer_fixed, 1);
	buffer_write(_buffer, buffer_string, _string);
	buffer_save(_buffer, _file_directory + "colour_grading.data");
	buffer_delete(_buffer);
}
//==============================================================================

function  __colour_grader_create_default_filter(_name)
{
	var _struct =
	{
		name                        : _name,
		strength	                : 1,  
		exposure_level              : 0,        
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

/// @param _filter_name  The name of the filter that you want to draw.  
/// @param [_surface] The surface which you want to apply the filter too. Default is the appication_surface.  
/// @param [_x]   
/// @param [_y]  

function colour_grader_draw(_filter_name, _surface = application_surface, _x = 0, _y = 0)
{
	
	
	if (!is_struct(global.__colour_grader_data_struct))
	{
		__colour_grader_init();
	}
	
	var _struct = global.__colour_grader_data_struct;
	
	if(_struct.editing)
	{
		_filter_name = _struct.selected_filter;
	}
	
	var _filter = _struct.filters[$ _filter_name];
	
	shader_set(sh_colour_grader);
	shader_set_uniform_f(_struct.strength, _filter.strength);
	shader_set_uniform_f(_struct.exposure, _filter.exposure_level);
	shader_set_uniform_f(_struct.contrast, _filter.contrast_level);
	shader_set_uniform_f(_struct.saturation, _filter.saturation_level);
	shader_set_uniform_f_array(_struct.lut_color_filter, _filter.lut_color_filter_array);
	shader_set_uniform_f_array(_struct.lut_vfx_shadows, _filter.lut_vfx_shadows_array);
	shader_set_uniform_f_array(_struct.lut_vfx_midtones, _filter.lut_vfx_midtones_array);
	shader_set_uniform_f_array(_struct.lut_vfx_hightlights, _filter.lut_vfx_hightlights_array);
	shader_set_uniform_f_array(_struct.lut_vfx_SMHranges, _filter.lut_vfx_SMHranges_array);
	draw_surface(_surface, _x, _y);
	shader_reset();
}

//==============================================================================

function colour_grader_lut_draw(_filter_name, _surface = application_surface, _x = 0, _y = 0)
{

	var _struct = global.__colour_grader_data_struct;
	var _filter = _struct.filters[$ _filter_name];
	
	if(!surface_exists(global.__colour_grader_lut_surface)) 
	{
		
		global.__colour_grader_lut_surface = surface_create(512,512); //sLUT;
		surface_set_target(global.__colour_grader_lut_surface);
		shader_set(sh_colour_grader);
		shader_set_uniform_f(_struct.strength, 1);
		shader_set_uniform_f(_struct.exposure, _filter.exposure_level);
		shader_set_uniform_f(_struct.contrast, _filter.contrast_level);
		shader_set_uniform_f(_struct.saturation, _filter.saturation_level);
		shader_set_uniform_f_array(_struct.lut_color_filter, _filter.lut_color_filter_array);
		shader_set_uniform_f_array(_struct.lut_vfx_shadows, _filter.lut_vfx_shadows_array);
		shader_set_uniform_f_array(_struct.lut_vfx_midtones, _filter.lut_vfx_midtones_array);
		shader_set_uniform_f_array(_struct.lut_vfx_hightlights, _filter.lut_vfx_hightlights_array);
		shader_set_uniform_f_array(_struct.lut_vfx_SMHranges, _filter.lut_vfx_SMHranges_array);
		draw_sprite(sLUT, 0, 0, 0);
		shader_reset();
		surface_reset_target();
		
	}

	gpu_set_tex_filter_ext(_struct.lut_tex, true);
	shader_set(sh_lut_draw);
	shader_set_uniform_f(_struct.lut_strength, _filter.strength);
	texture_set_stage(_struct.lut_tex, surface_get_texture(global.__colour_grader_lut_surface));
	draw_surface(_surface, _x, _y);
	shader_reset();
	
}

//==============================================================================

function colour_grader_clean_up()
{
	if(surface_exists(global.__colour_grader_lut_surface))
	{
		surface_free(global.__colour_grader_lut_surface);
	}
}

//==============================================================================
//==============================================================================

function colour_grader_editing_window(_active)
{
	if (_active)
	{
		if (!instance_exists(imgui))
		{
			instance_create_depth(0, 0, 0, imgui);
			imguigml_add_font_from_ttf("pixel04b24.ttf", 12.0);	
		}
		if (global.__colour_grader_data_struct.selected_filter == "")
		{
			var _filter = global.__colour_grader_data_struct.filters;
			var _names = variable_struct_get_names(global.__colour_grader_data_struct.filters);
			if (is_struct(_filter[$ _names[0]]))
			{
				global.__colour_grader_data_struct.selected_filter = _filter[$ _names[0]].name;
			}
			else
			{
				global.__colour_grader_data_struct.first_filter = __colour_grader_create_default_filter("first_filter");
				global.__colour_grader_data_struct.selected_filter = "first_filter";
			}
		}
		
		imguigml_activate();
		global.__colour_grader_data_struct.editing = _active;
	}
	else 
	{
		imguigml_deactivate();
		global.__colour_grader_data_struct.editing = _active;
		return _active;
	}
	
	
	if (!imguigml_ready())
	{
		return _active;	
	}
	
	//==========================================================================
	
	imguigml_set_next_window_size(500, 600, EImGui_Cond.Once);
	imguigml_set_next_window_pos(140, 140, EImGui_Cond.Once);
	
	// 1024 is the menu bar flag.
	var ret = imguigml_begin("screen VFX", _active, 1024);
	if (!ret[1])
	{
		imguigml_deactivate();
		global.__colour_grader_data_struct.editing = _active;
		return false;
	}
	
	//==========================================================================
	
	imguigml_begin_menu_bar();
	
	if (imguigml_begin_menu("file"))
	{
		imguigml_menu_item("new");
		{
			//open a box to name the new filter
		}
		
		if (imguigml_menu_item("save"))
		{
			__colour_grader_save_file();
		}
		
		if (imguigml_menu_item("load"))
		{
			__colour_grader_load_file();
		}
		
		if (imguigml_menu_item("delete"))
		{
			//open a box asking if you want to delete this current filter.
		}
		
		imguigml_end_menu(); 
	}
	
	imguigml_end_menu_bar();


	//==========================================================================
	
	imguigml_text("select grading setup");
	
	var _struct = global.__colour_grader_data_struct.filters[$ global.__colour_grader_data_struct.selected_filter];
	
	if (imguigml_begin_combo("##select_premade", _struct.name))
	{
		var _filter = global.__colour_grader_data_struct.filters;
		var _names = variable_struct_get_names(global.__colour_grader_data_struct.filters);
		var _num = array_length(_names);
	
		for (var _i = 0; _i < _num; _i++)
		{
			var _input = imguigml_selectable(_filter[$ _names[_i]].name); 
			if(_input[0])
			{
				global.__colour_grader_data_struct.selected_filter = _filter[$ _names[_i]].name;
				colour_grader_clean_up();
				return _active;
			}
		}
		imguigml_end_combo();
	}

	imguigml_separator();

	//==============================================================================

	var _input = imguigml_input_text("change name",_struct.name, 1000);
	if(_input[0])
	{
		variable_struct_remove(global.__colour_grader_data_struct.filters, _struct.name);
		_struct.name = _input[1];
		global.__colour_grader_data_struct.filters[$ _struct.name] = _struct;
		global.__colour_grader_data_struct.selected_filter = _input[1];
	}
	
	imguigml_separator();
	
	//==============================================================================
	
	imguigml_text(_struct.name);
	
	var _min = 0;
	var _max = 1;
	var _input = imguigml_slider_float("strength",_struct.strength, _min, _max);
	if(_input[0])
	{
		_struct.strength = _input[1];
		colour_grader_clean_up();
	}
	
	
	var _min = 0;
	var _max = 6.5;
	var _input = imguigml_slider_float("exposure_level",_struct.exposure_level, _min, _max);
	if(_input[0])
	{
		_struct.exposure_level = _input[1];
		colour_grader_clean_up();
	}
		
	var _min = 0;
	var _max = 10;
	var _input = imguigml_slider_float("contrast_level",_struct.contrast_level, _min, _max);
	if(_input[0])
	{
		_struct.contrast_level = _input[1];
		colour_grader_clean_up();
	}	
		
	var _min = 0;
	var _max = 5;
	var _input = imguigml_slider_float("saturation_level",_struct.saturation_level, _min, _max);
	if(_input[0])
	{
		_struct.saturation_level = _input[1];
		colour_grader_clean_up();
	}
		
	var _min = 0;
	var _max = 1;
	var _array = _struct.lut_color_filter_array;
	var _input = imguigml_slider_float3("color_filter",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_color_filter_array = [_input[1],_input[2], _input[3]];
		colour_grader_clean_up();
	}
		
	imguigml_separator();
		
	var _min = 0;
	var _max = 3;
	var _array = _struct.lut_vfx_shadows_array;
	var _input = imguigml_slider_float3("shadows",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_shadows_array = [_input[1],_input[2], _input[3]];
		colour_grader_clean_up();
	}
		
	var _min = 0;
	var _max = 3;
	var _array = _struct.lut_vfx_midtones_array;
	var _input = imguigml_slider_float3("midtones",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_midtones_array = [_input[1],_input[2], _input[3]];
		colour_grader_clean_up();
	}
		
	var _min = 0;
	var _max = 3;
	var _array = _struct.lut_vfx_hightlights_array;
	var _input = imguigml_slider_float3("hightlights",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_hightlights_array = [_input[1],_input[2], _input[3]];
		colour_grader_clean_up();
	}
		
	var _min = 0;
	var _max = 1;
	var _array = _struct.lut_vfx_SMHranges_array;
	var _input = imguigml_slider_float4("SMHRanges",_array[0], _array[1], _array[2], _array[3],_min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_SMHranges_array = [_input[1],_input[2], _input[3], _input[4]];
		colour_grader_clean_up();
	}
	
	imguigml_separator();
	
	//==============================================================================
	
	var _input = imguigml_button("Randomize_screen_VFX");
	if (_input)
	{
		_struct.strength =  random(1);
		_struct.exposure_level = random(2);
		_struct.contrast_level = random(5);
		_struct.saturation_level = random(5);
		_struct.lut_color_filter_array = [random(1), random(1), random(1)];
		_struct.lut_vfx_shadows_array = [random(3), random(3), random(3)];
		_struct.lut_vfx_midtones_array = [random(3), random(3), random(3)];
		_struct.lut_vfx_hightlights_array = [random(3), random(3), random(3)];
		colour_grader_clean_up();
	}	
	
	imguigml_same_line();
	
	var _input = imguigml_button("reset to default");
	if (_input)
	{
		global.__colour_grader_data_struct.filters[$ global.__colour_grader_data_struct.selected_filter] = __colour_grader_create_default_filter(_struct.name);
		colour_grader_clean_up();
	}	
	
	imguigml_separator();
	
	imguigml_end_child(); 
	
	imguigml_end();
	
	
	return _active;
}



