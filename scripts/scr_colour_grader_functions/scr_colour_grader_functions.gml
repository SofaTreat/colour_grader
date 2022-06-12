/*DOCUMENTATION

If you want to be able to edit, create, and delete filters then you need ImGuiGML. If you don't have it already, it is included in this package you can also find it for free online :)

HOW TO USE

Drag oColour_grader into your room in the room editor. set filter_name in the variable definitions to the name of a filter (as a string) you would like to use.
Four filters have been provided.

FILTER NAMES

"toxic"

"bloodmachine"

"frostmore"

"vampireholiday"

press F1 to access the editing box.

FUNCTIONS
colour_grader_draw(_filter_name,[_surface], [_x], [_y])
Takes the name of the filter as a string. By default this will draw the application surface at x:0,y:0 with the colour grading shader. Best to be called in a Draw GUI event. Unless you know what you are doing when it comes to surfaces.

colour_grader_lut_draw(_filter_name,[_surface], [_x], [_y])
Takes the name of the filter as a string. By default this will draw the application surface at x:0,y:0 with the colour grading shader. Best to be called in a Draw GUI event. Unless you know what you are doing when it comes to surfaces. The function does the colour filtering to a lut surface once, and then samples from that surface to apply the filter to the screen.
Pros of this function over colour_grader_draw()
It's a possibly faster shader. Maybe.
Cons
You now have a surface to deal with which needs to be destoryed with colour_grader_clean_up(); Or you will have a memory leak.
You may get a slight amount of colour banding.

colour_grader_clean_up()
checks to see if colour_grader_lut_draw() has created a surface and frees it. call this in a cleanup event to avoid any memory leaks.

__colour_grader_trace_filter_names()
This function prints out a list of filter names you have to the output log.

__colour_grader_init()
sets up everything you need to run the colour gradering filter. colour_grade_draw and colour_grader_lut_draw do both take care of this for you. But you can run it in the create of something if you want to keep your draw step clean.

colour_grader_editing_window(bool); NEEDS IMGUIGML TO WORK.
creates an editing window where you can create and edit filters. Dont forget to save any changes you have made! If you do not have imguigml in your project, you may want to go and delete this function.
If you want to be able to close the window using the little x in the corner, then write it out like this:
if (keyboard_check_pressed(vk_f1))
{
	open_window = ! open_window;
}
open_window = colour_grader_editing_window(open_window);


Directories!
by default oColour_grader saves its data to the working_directory, I can't guarantee the datas safety there so I would make backups. You can find your colour_grading.data file in user -> appData -> local -> project name folder. but if you want to save and load that file to and from the project directory, (ie to keep everything in a git repo) there is a file called "pre_run_step.bat" in the datafiles, move that into the project root folder to be able to save data into the project file. for this to work you need to turn off file sandboxing in the windows options of your project. This also only works for windows.

Shout outs to Rousr for ImGuiGml, Juju for Directory pathing and Gaming Reverend for the original lut shader.
*/


function __colour_grader_init()
{
	var _filters = __colour_grader_load_file();
	
	var _colour_grader = 
	{
		lut_tex					: shader_get_sampler_index(sh_lut_draw, "lut_tex"),
		lut_strength			: shader_get_uniform(sh_lut_draw, "strength"),
		strength      			: shader_get_uniform(sh_colour_grader, "strength"),
		exposure      			: shader_get_uniform(sh_colour_grader, "exposure"),
		contrast        		: shader_get_uniform(sh_colour_grader, "contrast"),
		saturation      		: shader_get_uniform(sh_colour_grader, "saturation"),
		lut_color_filter		: shader_get_uniform(sh_colour_grader, "color_filter"),
		lut_vfx_shadows			: shader_get_uniform(sh_colour_grader, "shadows"),
		lut_vfx_midtones		: shader_get_uniform(sh_colour_grader, "midtones"),
		lut_vfx_hightlights		: shader_get_uniform(sh_colour_grader, "highlights"),
		lut_vfx_SMHranges		: shader_get_uniform(sh_colour_grader, "SMHranges"),
		filters             	: _filters,
		selected_filter     	: "",
		editing             	: false,
		create_new_filter   	: false,
		create_new_filter_name  : "",
		delete_current_filter   : false,
		change_filter_name      : false,
		active_filter           : __colour_grader_create_default_filter(""),
		lerp_filter             : __colour_grader_create_default_filter("lerp"),
		filter_to_lerp_to       : "",
		lerp_speed              : 1,
		lerping_filter          : false,
		lerp_timer              : 0,
		redraw_lut_surface      : false,
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
		var _file = working_directory + "premade_filters.data";
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
	}

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

function colour_grader_get_filter()
{
	return 	global.__colour_grader_data_struct.active_filter.name;
}

//==============================================================================

function colour_grader_set_filter(_filter_name, _lerp_time_in_frames = 1)
{
	//do we exist? if not self create!
	if (!variable_global_exists("__colour_grader_data_struct"))
	or (!is_struct(global.__colour_grader_data_struct))
	{
		__colour_grader_init();
	}
	
	var _struct = global.__colour_grader_data_struct;
	//tests to see if this struct is a valid filter, if not will print a list of valid filters to your output log and throw an error.
	if(!is_struct(_struct.filters[$ _filter_name]))
	{
		 __colour_grader_trace_filter_names();	
		throw ("Invalid filter name string: A list of valid filter names has been printed in output log."); 
	}

	//setup
	_struct.filter_to_lerp_to = _filter_name;
	_struct.lerp_speed = _lerp_time_in_frames;
	_struct.lerping_filter = true;
	_struct.lerp_timer = 0;
	
	_struct.active_filter.name = _filter_name;
	
	//copies the current filter settings over to the lerp_to_filter so we can lerp from that to the new filter.
	var _string, _name_array = variable_struct_get_names(_struct.active_filter);
	var _num = array_length(_name_array);
	for(var _i = 0; _i < _num; _i++)
	{
		_string = _name_array[_i];
		if (_string == "name")
		{
			continue;
		}
		
		if(is_array(_struct.active_filter[$ _string]))
		{
			var _array_num = array_length(_struct.active_filter[$ _string]);
			for(var _j = 0; _j < _array_num; _j++)
			{
				_struct.lerp_filter[$ _string][_j] = _struct.active_filter[$ _string][_j]; 
			}
		}
		else
		{
			_struct.lerp_filter[$ _string] = _struct.active_filter[$ _string]; 
		}
	}
	
}

function __colour_grader_lerp_to_filter() 
{
	var _struct = global.__colour_grader_data_struct;
	_struct.redraw_lut_surface = true;
	var _filter_name = _struct.filter_to_lerp_to;

	var _lerp_to_filter = _struct.filters[$ _filter_name];
	var _lerp_from_filter = global.__colour_grader_data_struct.lerp_filter;
	
	var _lerp_speed = _struct.lerp_speed;
	if (_lerp_speed < 1)
	{
		_lerp_speed = 1;
	}
	
	_struct.lerp_timer += 1/ _lerp_speed;
	
	if(_struct.lerp_timer >= 1)
	{
		_struct.lerp_timer = 1;
	}
	

	
	var _string, _name_array = variable_struct_get_names(_struct.active_filter);
	var _num = array_length(_name_array);
	for(var _i = 0; _i < _num; _i++)
	{
		_string = _name_array[_i];
		if (_string == "name")
		{
			continue;
		}
		
		if(is_array(_struct.active_filter[$ _string]))
		{
			var _array_num = array_length(_struct.active_filter[$ _string]);
			for(var _j = 0; _j < _array_num; _j++)
			{
				_struct.active_filter[$ _string][_j] = lerp(_lerp_from_filter[$ _string][_j], _lerp_to_filter[$ _string][_j], _struct.lerp_timer); 
			}
		}
		else
		{
			_struct.active_filter[$ _string] = lerp(_lerp_from_filter[$ _string], _lerp_to_filter[$ _string], _struct.lerp_timer); 
		}
	}
	
	if(_struct.lerp_timer >= 1)
	{
		_struct.lerp_timer = 0;
		_struct.lerping_filter = false;
	}
}


//==============================================================================

/// @param [_surface] The surface which you want to apply the filter too. Default is the appication_surface.  
/// @param [_x]   the x position to draw the surface at. 
/// @param [_y]   the y position to draw the surface at. 

function colour_grader_draw(_surface = application_surface, _x = 0, _y = 0)
{
	if (!variable_global_exists("__colour_grader_data_struct"))
	or (!is_struct(global.__colour_grader_data_struct))
	{
		__colour_grader_init();
	}
	
	var _struct = global.__colour_grader_data_struct;
	
	if(_struct.editing)
	{
		var _filter_name = _struct.selected_filter;
		var _filter = _struct.filters[$ _filter_name];
	}
	else
	{
		var _filter = _struct.active_filter;
	}
	
	
	if (_struct.lerping_filter)
	{
		__colour_grader_lerp_to_filter();
	}
	
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

function __colour_grader_trace_filter_names()
{
	if (!variable_global_exists("__colour_grader_data_struct"))
	or (!is_struct(global.__colour_grader_data_struct))
	{
		__colour_grader_init();
	}
	
	show_debug_message("************");
	show_debug_message("FILTER NAMES");
	show_debug_message("************");
	
	var _names = variable_struct_get_names(global.__colour_grader_data_struct.filters);
	var _num = array_length(_names);
	for (var _i = 0; _i < _num; _i++)
	{
		show_debug_message(_names[_i]);
	}
	
	show_debug_message("************");
}

//==============================================================================

/// @param [_surface] The surface which you want to apply the filter too. Default is the appication_surface.  
/// @param [_x]   the x position to draw the surface at. 
/// @param [_y]   the y position to draw the surface at. 

function colour_grader_lut_draw(_surface = application_surface, _x = 0, _y = 0)
{
	if (!variable_global_exists("__colour_grader_data_struct"))
	or (!is_struct(global.__colour_grader_data_struct))
	{
		__colour_grader_init();
	}

	
	var _struct = global.__colour_grader_data_struct;
	
	if(_struct.editing)
	{
		var _filter_name = _struct.selected_filter;
		var _filter = _struct.filters[$ _filter_name];
	}
	else
	{
		var _filter = _struct.active_filter;
	}
	
	
	if (_struct.lerping_filter)
	{
		__colour_grader_lerp_to_filter();
	}
	
	if(global.__colour_grader_data_struct.redraw_lut_surface) 
	{
		if(!surface_exists(global.__colour_grader_lut_surface))
		{
			global.__colour_grader_lut_surface = surface_create(512,512); //sLUT;
		}
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
		global.__colour_grader_data_struct.redraw_lut_surface = false;
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
		if (!variable_global_exists("__colour_grader_data_struct"))
		or (!is_struct(global.__colour_grader_data_struct))
		{
			__colour_grader_init();
		}
		
		if (!instance_exists(imgui))
		{
			instance_create_depth(0, 0, 0, imgui);
			imguigml_add_font_from_ttf("pixel04b24.ttf", 12.0);	
		}
		
		if (!global.__colour_grader_data_struct.editing)
		{
			if (global.__colour_grader_data_struct.active_filter.name == "")
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
			else
			{
				global.__colour_grader_data_struct.selected_filter = global.__colour_grader_data_struct.active_filter.name;
			}
		}
		
		global.__colour_grader_data_struct.editing = true;
		
		imguigml_activate();
	}
	else 
	{
		imguigml_deactivate();
		if (global.__colour_grader_data_struct.editing)
		{
			colour_grader_set_filter(global.__colour_grader_data_struct.selected_filter, 1);
		}
		global.__colour_grader_data_struct.editing = false;
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
		if (global.__colour_grader_data_struct.editing)
		{
			colour_grader_set_filter(global.__colour_grader_data_struct.selected_filter, 1);
		}
		global.__colour_grader_data_struct.editing = false;
		return false;
	}
	
	var _struct = global.__colour_grader_data_struct.filters[$ global.__colour_grader_data_struct.selected_filter];
	
	//==========================================================================
	
	imguigml_begin_menu_bar();
	
	if (imguigml_begin_menu("file"))
	{
		if (imguigml_menu_item("new"))
		{
			//open a box to name the new filter
			global.__colour_grader_data_struct.create_new_filter = true;
			global.__colour_grader_data_struct.create_new_filter_name = "";
		}
		
		if (imguigml_menu_item("save"))
		{
			__colour_grader_save_file();
		}
		
		if (imguigml_menu_item("load"))
		{
			global.__colour_grader_data_struct.filters = __colour_grader_load_file();
		}
		
		if (imguigml_menu_item("delete"))
		{
			global.__colour_grader_data_struct.delete_current_filter = true;
		}
		
		imguigml_end_menu(); 
	}
	
	imguigml_end_menu_bar();

	
	if (global.__colour_grader_data_struct.create_new_filter)
	{
		var _input = imguigml_input_text("name of filter", global.__colour_grader_data_struct.create_new_filter_name, 100);
		if(_input[0])
		{
			global.__colour_grader_data_struct.create_new_filter_name = _input[1];
		}

		var _valid_name = true;
		var _new_filter_name = global.__colour_grader_data_struct.create_new_filter_name;
		if (_new_filter_name == "")
		{
			_valid_name = false;
		}
		var _names = variable_struct_get_names(global.__colour_grader_data_struct.filters);
		var _num = array_length(_names);
		for (var _i = 0; _i < _num; _i++)
		{
			if (_new_filter_name == _names[_i])
			{
				_valid_name = false;
			}
		}
		
		if (_valid_name) {imguigml_text("Name is valid."); }	
		else {imguigml_text("Name is not valid. (A filter name cannot be empty or the same as another filter name)"); }	
			
		if (imguigml_button("confirm"))
		{
			if (_valid_name)
			{
				global.__colour_grader_data_struct.filters[$ _new_filter_name] = __colour_grader_create_default_filter(_new_filter_name);
				global.__colour_grader_data_struct.create_new_filter = false;
				global.__colour_grader_data_struct.create_new_filter_name = "";
				global.__colour_grader_data_struct.selected_filter = _new_filter_name;
				
			}
		}
		
		
		imguigml_same_line();
		
		if (imguigml_button("cancel"))
		{
			global.__colour_grader_data_struct.create_new_filter = false;
			global.__colour_grader_data_struct.create_new_filter_name = "";
		}
		
		return _active;
	}
	
	
	if (global.__colour_grader_data_struct.delete_current_filter)
	{

		imguigml_text("Are you sure you want to delete this filter: " + global.__colour_grader_data_struct.selected_filter); 	
			
		if (imguigml_button("confirm"))
		{
			variable_struct_remove(global.__colour_grader_data_struct.filters, global.__colour_grader_data_struct.selected_filter);
			
			if (variable_struct_names_count(global.__colour_grader_data_struct.filters) <= 0)
			{
				global.__colour_grader_data_struct.first_filter = __colour_grader_create_default_filter("first_filter");
				global.__colour_grader_data_struct.selected_filter = "first_filter";
				global.__colour_grader_data_struct.delete_current_filter = false;
			}
			else
			{
				var _names = variable_struct_get_names(global.__colour_grader_data_struct.filters);
				global.__colour_grader_data_struct.selected_filter = _names[0];
				global.__colour_grader_data_struct.delete_current_filter = false;
			}
		}
		
		
		imguigml_same_line();
		
		if (imguigml_button("cancel"))
		{
			global.__colour_grader_data_struct.delete_current_filter = false;
		}
		
		return _active;
	}
	

	if (global.__colour_grader_data_struct.change_filter_name)
	{
		var _input = imguigml_input_text("change filter name", global.__colour_grader_data_struct.create_new_filter_name, 100);
		if(_input[0])
		{
			global.__colour_grader_data_struct.create_new_filter_name = _input[1];
		}

		var _valid_name = true;
		var _new_filter_name = global.__colour_grader_data_struct.create_new_filter_name;
		if (_new_filter_name == "")
		{
			_valid_name = false;
		}
		var _names = variable_struct_get_names(global.__colour_grader_data_struct.filters);
		var _num = array_length(_names);
		for (var _i = 0; _i < _num; _i++)
		{
			if (_new_filter_name == _names[_i])
			{
				_valid_name = false;
			}
		}
		
		if (_valid_name) {imguigml_text("Name is valid."); }	
		else {imguigml_text("Name is not valid. (A filter name cannot be empty or the same as another filter name)"); }	
			
		if (imguigml_button("confirm"))
		{
			if (_valid_name)
			{
				variable_struct_remove(global.__colour_grader_data_struct.filters, global.__colour_grader_data_struct.selected_filter);
				_struct.name = _new_filter_name;
				global.__colour_grader_data_struct.filters[$ _new_filter_name] = _struct;
				global.__colour_grader_data_struct.selected_filter = _new_filter_name;
				global.__colour_grader_data_struct.change_filter_name = false;
			}
		}
		
		
		imguigml_same_line();
		
		if (imguigml_button("cancel"))
		{
			global.__colour_grader_data_struct.change_filter_name = false;
			global.__colour_grader_data_struct.create_new_filter_name = "";
		}
		
		
		return _active;
		
	}
	
	//==========================================================================
	
	imguigml_text("select grading setup");
	

	
	if (imguigml_begin_combo("##select_premade", _struct.name))
	{
		var _filter = global.__colour_grader_data_struct.filters;
		var _names = variable_struct_get_names(_filter);
		var _num = array_length(_names);
	
		for (var _i = 0; _i < _num; _i++)
		{
			var _input = imguigml_selectable(_filter[$ _names[_i]].name); 
			if(_input[0])
			{
				global.__colour_grader_data_struct.selected_filter = _filter[$ _names[_i]].name;
				global.__colour_grader_data_struct.redraw_lut_surface = true;
				return _active;
			}
		}
		imguigml_end_combo();
	}

	imguigml_separator();

	//==============================================================================


	if(imguigml_button("change name"))
	{
		global.__colour_grader_data_struct.change_filter_name = true;
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
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
	
	
	var _min = 0;
	var _max = 6.5;
	var _input = imguigml_slider_float("exposure_level",_struct.exposure_level, _min, _max);
	if(_input[0])
	{
		_struct.exposure_level = _input[1];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
		
	var _min = 0;
	var _max = 10;
	var _input = imguigml_slider_float("contrast_level",_struct.contrast_level, _min, _max);
	if(_input[0])
	{
		_struct.contrast_level = _input[1];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}	
		
	var _min = 0;
	var _max = 5;
	var _input = imguigml_slider_float("saturation_level",_struct.saturation_level, _min, _max);
	if(_input[0])
	{
		_struct.saturation_level = _input[1];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
		
	var _min = 0;
	var _max = 1;
	var _array = _struct.lut_color_filter_array;
	var _input = imguigml_slider_float3("color_filter",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_color_filter_array = [_input[1],_input[2], _input[3]];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
		
	imguigml_separator();
		
	var _min = 0;
	var _max = 3;
	var _array = _struct.lut_vfx_shadows_array;
	var _input = imguigml_slider_float3("shadows",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_shadows_array = [_input[1],_input[2], _input[3]];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
		
	var _min = 0;
	var _max = 3;
	var _array = _struct.lut_vfx_midtones_array;
	var _input = imguigml_slider_float3("midtones",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_midtones_array = [_input[1],_input[2], _input[3]];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
		
	var _min = 0;
	var _max = 3;
	var _array = _struct.lut_vfx_hightlights_array;
	var _input = imguigml_slider_float3("hightlights",_array[0], _array[1], _array[2], _min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_hightlights_array = [_input[1],_input[2], _input[3]];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}
		
	var _min = 0;
	var _max = 1;
	var _array = _struct.lut_vfx_SMHranges_array;
	var _input = imguigml_slider_float4("SMHRanges",_array[0], _array[1], _array[2], _array[3],_min, _max);
	if(_input[0])
	{
		_struct.lut_vfx_SMHranges_array = [_input[1],_input[2], _input[3], _input[4]];
		global.__colour_grader_data_struct.redraw_lut_surface = true;
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
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}	
	
	imguigml_same_line();
	
	var _input = imguigml_button("reset to default");
	if (_input)
	{
		global.__colour_grader_data_struct.filters[$ global.__colour_grader_data_struct.selected_filter] = __colour_grader_create_default_filter(_struct.name);
		global.__colour_grader_data_struct.redraw_lut_surface = true;
	}	
	
	imguigml_separator();
	
	imguigml_end_child(); 
	
	imguigml_end();
	
	
	return _active;
}



