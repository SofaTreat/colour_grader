
if (keyboard_check_pressed(vk_f1))
{
	open_window = ! open_window;
}
open_window = colour_grader_editing_window(open_window);


if (keyboard_check_pressed(vk_f2))
{
	colour_grader_set_filter("toxic", 120);
}

if (keyboard_check_pressed(vk_f3))
{
	colour_grader_set_filter("bloodmachine", 80);
}

if (keyboard_check_pressed(vk_f4))
{
	colour_grader_set_filter("frostmore", 200);
}

if (keyboard_check_pressed(vk_f5))
{
	colour_grader_set_filter("vampireholiday");
}