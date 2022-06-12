
//opens the editing window.
if (keyboard_check_pressed(vk_f1))
{
	open_window = ! open_window;
}
open_window = colour_grader_editing_window(open_window);

//These are examples.
//you can set a new filter at anypoint, and then set the number of frames it will take to complete the transition.
//Leaving it empty, will set it to 1, which is an instant transition.
if (keyboard_check_pressed(vk_f2))
{
	colour_grader_set_filter("toxic", 120);
	show_debug_message(colour_grader_get_filter());
}

if (keyboard_check_pressed(vk_f3))
{
	colour_grader_set_filter("bloodmachine", 80);
	show_debug_message(colour_grader_get_filter());
}

if (keyboard_check_pressed(vk_f4))
{
	colour_grader_set_filter("frostmore", 800);
	show_debug_message(colour_grader_get_filter());
}

if (keyboard_check_pressed(vk_f5))
{
	colour_grader_set_filter("vampireholiday");
	show_debug_message(colour_grader_get_filter());
}