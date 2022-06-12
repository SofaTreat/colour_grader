DOCUMENTATION

 If you want to be able to edit, create, and delete filters then you need ImGuiGML. If you don't have it already, it is included in this package you can also find it for free online :)

 HOW TO USE

Drag oColour_grader into your room in the room editor.
Four filters have been provided. 

Press f2 for "toxic" 

Press f3 for "bloodmachine"

Press f4 for "frostmore"

Press f5 for "vampireholiday"

Press F1 to access the editing box.

*****

FUNCTIONS

```colour_grader_set_filter(_filter_name, [_lerp_time_in_frames = 1])```
Takes the name of the filter to wish to change to,
and how long in frames you want the change to take. Default is 1 frame.


```colour_grader_get_filter()```
//Returns the currect filter name as a string.


```colour_grader_draw([_surface], [_x], [_y]) ```

By default this will draw the application surface at x:0,y:0 with the colour grading shader.
Best to be called in a Draw GUI event. Unless you know what you are doing when it comes to surfaces.



```colour_grader_lut_draw([_surface], [_x], [_y]) ```

By default this will draw the application surface at x:0,y:0 with the colour grading shader.
Best to be called in a Draw GUI event. Unless you know what you are doing when it comes to surfaces. 
The function does the colour filtering to a lut surface once, and then samples from that surface to apply the filter to the screen.
1. Pros of this function over colour_grader_draw()
- It's a possibly faster shader. Maybe.
2. Cons
- You now have a surface to deal with which needs to be destoryed with colour_grader_clean_up(); Or you will have a memory leak.
- You may get a slight amount of colour banding.



```colour_grader_clean_up()```

checks to see if colour_grader_lut_draw() has created a surface and frees it.
call this in a cleanup event to avoid any memory leaks.



```colour_grader_editing_window(bool); ```NEEDS IMGUIGML TO WORK.

creates an editing window where you can create and edit filters. 
Dont forget to save any changes you have made!
If you do not have imguigml in your project, you may want to go and delete this function.

If you want to be able to close the window using the little x in the corner, then write it out like this:
```
if (keyboard_check_pressed(vk_f1))
{
	open_window = ! open_window;
}
open_window = colour_grader_editing_window(open_window);
```

*****

 Directories!
 
 by default oColour_grader saves its data to the working_directory, I can't guarantee the datas safety there, so I would make backups. 
 You can find your colour_grading.data file in user -> appData -> local -> project name folder.
 but if you want to save and load that file to and from the project directory, (ie to keep everything in a git repo)
 there is a file called "pre_run_step.bat" in the datafiles. Move that into the project root folder to be able to save data into the project file.
 for this to work you need to turn off file sandboxing in the windows options of your project.
This also only works for windows.

 Shout outs to Rousr for ImGuiGml, Juju for Directory pathing and Gaming Reverend for the original lut shader.  
