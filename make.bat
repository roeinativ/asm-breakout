@echo off
echo Assembling the code...
tasm /zi main.asm
if errorlevel 1 goto error
echo Linking the object file...
tlink /v main.obj
if errorlevel 1 goto error
echo Build successful!
goto end

:error
echo Build failed! Check the error messages above.
:end
