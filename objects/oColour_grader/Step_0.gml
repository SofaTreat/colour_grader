
//==============================================================================


if (keyboard_check_pressed(vk_f1))
{
	window_settings_active = !window_settings_active;
	
	if (!instance_exists(imgui))
	{

		instance_create_depth(0, 0, 0, imgui);
		imguigml_add_font_from_ttf("pixel04b24.ttf", 12.0);	
	}
	
	if (window_settings_active)
	{
		imguigml_activate();
	}
	else
	{
		imguigml_deactivate();
	}
}

if (!window_settings_active) { exit; }


if (!imguigml_ready())
{
	exit;	
}


//==============================================================================


imguigml_set_next_window_size(500, 600, EImGui_Cond.Once);
imguigml_set_next_window_pos(140, 140, EImGui_Cond.Once);
var ret = imguigml_begin("screen VFX", true);
if (!ret[1])
{
	window_settings_active = false;
	imguigml_deactivate();
	exit;
}

//==============================================================================

var _input = imguigml_button("save to file");
if (_input)
{
	colour_grading_save_file(file_directory, colour_grading_array);
}	

imguigml_same_line();

var _input = imguigml_button("load from file");
if (_input)
{
	colour_grading_load_file(file_directory);
}	


imguigml_separator();
imguigml_separator();
//==============================================================================

imguigml_text("select grading setup");

var _struct = colour_grading_struct;

if (imguigml_begin_combo("##select_premade", _struct.name))
{
	
	var _num = array_length(colour_grading_array);

	for (var _i = 0; _i < _num; _i++)
	{
		var _input = imguigml_selectable(colour_grading_array[_i].name); 
		if(_input[0])
		{
			colour_grading_struct_selected = _i;
			colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
			setup_lut_vfx();
			exit;
		}
	}
	imguigml_end_combo();
}

imguigml_same_line();

var _input = imguigml_button("<");
if (_input)
{
	colour_grading_struct_selected--;
	if (colour_grading_struct_selected < 0)
	{
		colour_grading_struct_selected = array_length(colour_grading_array) -1;
	}
	
	change_lut_setup(colour_grading_struct_selected);
}	

imguigml_same_line();

var _input = imguigml_button(">");
if (_input)
{
	change_lut_setup(colour_grading_struct_selected++);
}	
imguigml_separator();


//==============================================================================

var _input = imguigml_button("create new LUT setup");
if (_input)
{
	colour_grading_struct_selected = array_length(colour_grading_array);
	colour_grading_array[colour_grading_struct_selected] = create_default_grading_struct();
	colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
	setup_lut_vfx();
}	

imguigml_same_line(); 

var _input = imguigml_button("delete current LUT setup");
if (_input)
{
	array_delete(colour_grading_array, colour_grading_struct_selected, 1);
	colour_grading_struct_selected--;
	
	if(colour_grading_struct_selected <= 0)
	{
		colour_grading_struct_selected = 0;
	}
	
	if (array_length(colour_grading_array) <= 0)
	{
		colour_grading_array[0] = create_default_grading_struct();
		colour_grading_struct_selected = 0;
	}

	colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
	setup_lut_vfx();
}	

//==============================================================================

imguigml_separator();

var _input = imguigml_input_text("change name",_struct.name, 100);
if(_input[0])
{
	_struct.name = _input[1];
}

imguigml_separator();

//==============================================================================

imguigml_text(_struct.name);

var _min = 0;
var _max = 1;
var _input = imguigml_slider_float("LUT_strength",_struct.lut_strength, _min, _max);
if(_input[0])
{
	_struct.lut_strength = _input[1];
	setup_lut_vfx();
}


var _min = 0;
var _max = 6.5;
var _input = imguigml_slider_float("exposure_level",_struct.exposure_level, _min, _max);
if(_input[0])
{
	_struct.exposure_level = _input[1];
	setup_lut_vfx();
}
	
var _min = 0;
var _max = 10;
var _input = imguigml_slider_float("contrast_level",_struct.contrast_level, _min, _max);
if(_input[0])
{
	_struct.contrast_level = _input[1];
	setup_lut_vfx();
}	
	
var _min = 0;
var _max = 5;
var _input = imguigml_slider_float("saturation_level",_struct.saturation_level, _min, _max);
if(_input[0])
{
	_struct.saturation_level = _input[1];
	setup_lut_vfx();
}
	
var _min = 0;
var _max = 1;
var _array = _struct.lut_color_filter_array;
var _input = imguigml_slider_float3("color_filter",_array[0], _array[1], _array[2], _min, _max);
if(_input[0])
{
	_struct.lut_color_filter_array = [_input[1],_input[2], _input[3]];
	setup_lut_vfx();
}
	
imguigml_separator();
	
var _min = 0;
var _max = 3;
var _array = _struct.lut_vfx_shadows_array;
var _input = imguigml_slider_float3("shadows",_array[0], _array[1], _array[2], _min, _max);
if(_input[0])
{
	_struct.lut_vfx_shadows_array = [_input[1],_input[2], _input[3]];
	setup_lut_vfx();
}
	
var _min = 0;
var _max = 3;
var _array = _struct.lut_vfx_midtones_array;
var _input = imguigml_slider_float3("midtones",_array[0], _array[1], _array[2], _min, _max);
if(_input[0])
{
	_struct.lut_vfx_midtones_array = [_input[1],_input[2], _input[3]];
	setup_lut_vfx();
}
	
var _min = 0;
var _max = 3;
var _array = _struct.lut_vfx_hightlights_array;
var _input = imguigml_slider_float3("hightlights",_array[0], _array[1], _array[2], _min, _max);
if(_input[0])
{
	_struct.lut_vfx_hightlights_array = [_input[1],_input[2], _input[3]];
	setup_lut_vfx();
}
	
var _min = 0;
var _max = 1;
var _array = _struct.lut_vfx_SMHranges_array;
var _input = imguigml_slider_float4("SMHRanges",_array[0], _array[1], _array[2], _array[3],_min, _max);
if(_input[0])
{
	_struct.lut_vfx_SMHranges_array = [_input[1],_input[2], _input[3], _input[4]];
	setup_lut_vfx();
}

imguigml_separator();

//==============================================================================

var _input = imguigml_button("Randomize_screen_VFX");
if (_input)
{
	randomize_screen_vfx();
}	

imguigml_same_line();

var _input = imguigml_button("reset to default");
if (_input)
{
	colour_grading_array[colour_grading_struct_selected] = create_default_grading_struct();
	colour_grading_struct = colour_grading_array[colour_grading_struct_selected];
	setup_lut_vfx();
}	

imguigml_separator();

imguigml_end_child(); 

imguigml_end();


//==============================================================================
//==============================================================================

