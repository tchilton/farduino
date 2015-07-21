@echo off 
Rem remotely upload the firmware to an intermediate server which will then perform the programming activity

rem where are we connecting to and as what
set host=chicken-coop-dev
set user=farduino
set cert="c:\code\Certificates\Chicken Coop Dev\Chicken Coop Dev Private.ppk"

rem name of the WinSCP profile that we will use - use certificates
set scpprofile="ChickenCoopDev"

if "%1" == "" goto Args

rem scp-file to the Raspberry Pi in the Chicken Coop, ready for a firmware update
winscp /command "option batch abort" "option confirm off" "open %scpprofile%" "put %1 /firmware/rotator/firmware.hex" "exit"
if %ERRORLEVEL% GTR 0 goto FAILED
echo .
echo .

rem now ssh into the system and run avrdude to apply the code
rem do not pass the local upload filename to the remote system
plink %user%@%host% -i %CERT% /firmware/rotator/upload %2 %3 %4 %5 %6 %7 %8 %9
if %ERRORLEVEL% GTR 0 goto FAILED

:Exit
goto :eof

:FAILED
echo Upload process failed
goto :eof

:Args
echo Arguments are missing
goto :eof