@echo off
echo symlink test

echo creating project directory link file...
@echo %YYprojectDir%\> "%YYoutputFolder%\projectDirectoryPath"

:: Make sure we don't have a symlink left over from the last run
del "%~dp0\symlinkToWorkingDirectory" /f /q
rmdir "%~dp0\symlinkToWorkingDirectory" /s /q

echo Creating symlink to working directory...
mklink /d "%~dp0\symlinkToWorkingDirectory" "%YYoutputFolder%\"

echo pre_run_step.bat complete
