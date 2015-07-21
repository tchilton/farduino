@echo off
rem FARDUINO - Remote Programming of Arduino microcontrollers via Raspberry Pi
rem re-run this after updating Arduino software if new folders exist in the %source% folder
rem so that it can create the necessary links
echo re-creating the linked folders

rem set this to where Arduino IDE is installed if not in the default folder
set sourceDrive=C:
set source="%sourceDrive%\Program Files (x86)\Arduino\hardware\arduino\avr"
set scripts=c:\scripts\farduino

rem The Arduino folder in your profile6
set destination="%USERPROFILE%\Documents\Arduino\hardware\my boards\avr"

rem ensure the target folder exists
if not exist "%USERPROFILE%\Documents\Arduino"				mkdir "%USERPROFILE%\Documents\Arduino"
if not exist "%USERPROFILE%\Documents\Arduino\hardware"			mkdir "%USERPROFILE%\Documents\Arduino\hardware"
if not exist "%USERPROFILE%\Documents\Arduino\hardware\My Boards"	mkdir "%USERPROFILE%\Documents\Arduino\hardware\My Boards"
if not exist "%USERPROFILE%\Documents\Arduino\hardware\My Boards\avr"	mkdir "%USERPROFILE%\Documents\Arduino\hardware\My Boards\avr"		

rem Copy the template files across, but dont overwrite any existing ones.
for %%d in (boards.txt platform.txt programmers.txt) do if not exist %destination%\%%d copy %%d %destination%

if not exist %scripts% xcopy /s Scripts %scripts% 

rem we need the Arduino standard files, so link them to here
rem this means if they are updated via Arduino, we will also see them here
cd %source%
%sourceDrive%
for /d %%s in (*.) do if not exist %destination%\\%%s mklink /j %destination%\%%s %source%\%%s 

echo Done.