@echo off

REM Destination folder for all result directories
set DEST_FOLDER=taurus-result

REM Create the destination if it doesn't exist
if not exist "%DEST_FOLDER%" mkdir "%DEST_FOLDER%"

REM Find all timestamped Taurus result folders (starts with a date)
echo Looking for Taurus result folders...

set FOUND_FOLDERS=0
for /d %%i in (202*) do (
    if not "%%i"=="%DEST_FOLDER%" (
        echo Found: %%i
        set /a FOUND_FOLDERS+=1
    )
)

REM Check and move each folder
if %FOUND_FOLDERS%==0 (
    echo ⚠️ No timestamped Taurus result folders found.
) else (
    echo 📦 Moving folders to %DEST_FOLDER%/ ...
    for /d %%i in (202*) do (
        if not "%%i"=="%DEST_FOLDER%" (
            echo   ➤ Moving %%i
            move "%%i" "%DEST_FOLDER%\"
        )
    )
    echo ✅ All folders moved successfully.
)

pause 