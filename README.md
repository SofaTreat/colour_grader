BASIC DOCUMENTATION

oColour_grader needs ImGuiGML to work. If you don't have it already and its not included in this package, you can find it for free online :)
Rousr makes ImGuiGML.

How to use!

Drag oColour_grader into your room in the room editor.

press F1 to access the editing box.

Use change_lut_setup(_setup)

to switch colour grading setups at any point, it accepts both the name of the setup as a string, or its position in the colour_grading_array.

Directories!

by default oColour_grader saves its data to the working_directory, I can't guarantee  the datas safety there so I would make backups. 

You can find your colour_grading.data file in user -> appData -> local -> project name folder.

but if you want to save and load that file to and from the project directory, (ie to keep everything in a git repo)

there is a file called "pre_run_step.bat" in the datafiles, move that into the project root folder to be able to save data into the project file.

for this to work you need to turn off file sandboxing in the windows options of your project.

This also only works for windows.

Shout outs to Rousr for ImGuiGml, Juju for Directory pathing and Gaming Reverend for the original lut shader.  
