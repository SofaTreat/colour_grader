 BASIC DOCUMENTATION

 oColour_grader needs ImGuiGML to work. If you don't have it already and its not included in this package, you can find it for free online :)
 Rousr makes ImGuiGML.
****
 How to use!

Drag oColour_grader into your room in the room editor.
 set filter_name in the variable definitions to the name string of a filter you would like to use.  
Four filters have been provided

FILTER NAMES

toxic

bloodmachine

frostmore

vampireholiday


 press F1 to access the editing box.

*****
FUNCTIONS
colour_grader_draw(_filter_name,[_surface], [_x], [_y])
Takes the name of the filter as a string.
By default this will draw the application surface at x:0,y:0 with the colour grading shader.
Best to be called in a Draw GUI event. Unless you know what you are doing when it comes to surfaces. 

colour_grader_lut_draw(_filter_name,[_surface], [_x], [_y])
Takes the name of the filter as a string.
By default this will draw the application surface at x:0,y:0 with the colour grading shader.
Best to be called in a Draw GUI event. Unless you know what you are doing when it comes to surfaces. 
The function does the colour filtering to a lut surface once, and then samples from that surface to apply the filter to the screen.
Pros of this function over colour_grader_draw()
	* It's a possibly faster shader. Maybe.
Cons
	* You now have a surface to deal with which needs to be destoryed with colour_grader_clean_up(); Or you will have a memory leak.
	* You may get a slight amount of colour banding.

colour_grader_clean_up()
checks to see if colour_grader_lut_draw() has created a surface and frees it.
call this in a cleanup event to avoid any memory leaks.


__colour_grader_trace_filter_names()
This function prints out a list of filter names you have to the output log.

__colour_grader_init()
sets up everything you need to run the colour gradering filter.


colour_grader_editing_window(bool); NEEDS IMGUIGML TO WORK.
creates an editing window where you can create and edit filters. 
Dont forget to save any changes you have made!
If you do not have imguigml in your project, you may want to go and delete this function.

*****
 Directories!
 by default oColour_grader saves its data to the working_directory, I can't guarantee  the datas safety there so I would make backups. 
 You can find your colour_grading.data file in user -> appData -> local -> project name folder.
 but if you want to save and load that file to and from the project directory, (ie to keep everything in a git repo)
 there is a file called "pre_run_step.bat" in the datafiles, move that into the project root folder to be able to save data into the project file.
 for this to work you need to turn off file sandboxing in the windows options of your project.
This also only works for windows.

 Shout outs to Rousr for ImGuiGml, Juju for Directory pathing and Gaming Reverend for the original lut shader.  
