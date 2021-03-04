:: Automatically upgrades an existing W:O install to a new version
:: Author: benson#0411
:: License: MIT

:: Initialize (stop command spam, clean screen, make variables work, set to UTF-8)
@echo off && cls
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >nul

:: Move to base folder, and make sure it worked (otherwise things would go horribly wrong)
pushd "%~dp0"
if !errorlevel! NEQ 0 goto error_location
if not exist server ( goto error_location )
if not exist utilities ( goto error_location )
if not exist wrapper ( goto error_location )
if not exist start_wrapper.bat ( goto error_location )
goto noerror_location
:error_location
echo Doesn't seem like this script is in the Wrapper: Offline folder.
echo Please move it to the same folder as start_wrapper.bat
goto end
:noerror_location

:: Check for an update to install
if not exist upgrade_assets goto error_noupdate
for %%i in (upgrade_assets\*) do ( goto noerror_noupdate )
:error_noupdate
echo Couldn't find an update to install.
echo You can check for new releases on our Discord server.
echo:
echo When downloading a new release, drag the upgrade_assets folder 
echo in the same folder as start_wrapper.bat and this script.
echo:
goto end
:noerror_noupdate

:: Prevents CTRL+C cancelling and keeps window open when crashing
if "%~1" equ "point_insertion" goto point_insertion
start "" /wait /B "%~F0" point_insertion
exit
:point_insertion

:: patch detection
if exist "patch.jpg" echo no amount of upgrades can fix a patch && goto end


:: Get info about update
call upgrade_assets\update_metadata.bat
title Upgrading Wrapper: Offline to !WRAPPER_NEWVER!

echo Would you like to upgrade to !WRAPPER_NEWVER!?
echo Update summary: !UPDATE_SUMMARY!
echo:
if !MODBREAKING!==y (
	echo Note: If you mod W:O often, you may want to look through
	echo the upgrade_assets folder to see what files you should back up.
	echo:
)
echo Press Y to install the update, press N to cancel.
echo:
:installaskretry
set /p INSTALLCHOICE= Response:
echo:
if not '!installchoice!'=='' set installchoice=%installchoice:~0,1%
if /i "!installchoice!"=="0" goto end
if /i "!installchoice!"=="y" goto startupdate
if /i "!installchoice!"=="n" goto end
if /i "!installchoice!"=="v" set VERBOSEMODE=y & goto startupdate
echo You must answer Yes or No. && goto installaskretry
:startupdate

cls
echo Please do not close this window^^!^^!
echo Doing so may ruin your copy of Wrapper: Offline.
echo It's almost certainly NOT frozen, just takes a while.
echo:

:: Execute prescript if needed
if exist upgrade_assets\extra_prescript.bat (
	if !VERBOSEMODE!==y (
		call upgrade_assets\extra_prescript.bat
	) else (
		call upgrade_assets\extra_prescript.bat >nul
	)
)

:: Delete any files no longer supposed to be in W:O
if exist upgrade_assets\removed_files.txt (
	if !VERBOSEMODE!==y (
		for /F "tokens=*" %%A in (upgrade_assets\removed_files.txt) do (
			del /q /s %%A
		)
	) else (
		for /F "tokens=*" %%A in (upgrade_assets\removed_files.txt) do (
			del /q /s %%A>nul
		)
	)
)

:: Replace files
:: I really don't wanna use robocopy, but I haven't found a method that works 100% yet
if !VERBOSEMODE!==y (
	robocopy .\upgrade_assets\new_files\ . /E /MOVE
) else (
	robocopy .\upgrade_assets\new_files\ . /E /MOVE>nul
)

:: Delete upgrade folder
if !VERBOSEMODE!==y (
	rd /q /s upgrade_assets
) else (
	rd /q /s upgrade_assets>nul
)

:: Execute postscript if needed
if exist upgrade_assets\extra_postscript.bat (
	if !VERBOSEMODE!==y (
		call upgrade_assets\extra_postscript.bat
	) else (
		call upgrade_assets\extra_postscript.bat>nul
	)
)

color 20
echo:
echo:
echo Update installed^^!
echo:

:end
endlocal
echo Closing...
pause & exit