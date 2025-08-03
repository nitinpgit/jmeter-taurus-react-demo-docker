@echo off
echo ========================================
echo Taurus Test Runner (Local Machine)
echo ========================================
echo.

REM Check if Taurus is installed
where bzt >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Taurus is not installed or not in PATH
    echo Please install Taurus using one of these methods:
    echo.
    echo Method 1 - Using pip:
    echo   pip install bzt
    echo.
    echo Method 2 - Using Docker:
    echo   docker run --rm -v %%cd%%:/bzt blazemeter/taurus:latest
    echo.
    echo Method 3 - Download from: https://gettaurus.org/install/Installation/
    echo.
    pause
    exit /b 1
)

echo Taurus found at: 
where bzt
echo.

echo Available Taurus test files:
echo.
echo 1. get-quick-message.yml
echo 2. get-delayed-response.yml
echo 3. post-create-data.yml
echo 4. test.yml (complete test suite)
echo.

set /p choice="Enter test number (1-4) or press Enter for quick message test: "

if "%choice%"=="" set choice=1

if "%choice%"=="1" (
    set TEST_FILE=taurus/get-quick-message.yml
    set TEST_NAME=Quick Message Test
) else if "%choice%"=="2" (
    set TEST_FILE=taurus/get-delayed-response.yml
    set TEST_NAME=Delayed Response Test
) else if "%choice%"=="3" (
    set TEST_FILE=taurus/post-create-data.yml
    set TEST_NAME=Create Data Test
) else if "%choice%"=="4" (
    set TEST_FILE=taurus/test.yml
    set TEST_NAME=Complete Test Suite
) else (
    echo Invalid choice. Using quick message test.
    set TEST_FILE=taurus/get-quick-message.yml
    set TEST_NAME=Quick Message Test
)

echo.
echo Running: %TEST_NAME%
echo Test file: %TEST_FILE%
echo.

REM Create results directory
if not exist "taurus-results" mkdir taurus-results

REM Set BlazeMeter credentials (optional - for cloud reporting)
REM Note: BlazeMeter credentials are configured in .bzt-rc file
echo BlazeMeter credentials are configured in .bzt-rc file
echo.

REM Run Taurus test
echo Starting Taurus test...
bzt "%TEST_FILE%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Test completed successfully!
    echo ========================================
    echo Results saved to: taurus-result\
    echo.
    echo Organizing test results...
    call move-taurus-results.bat
    echo.
    echo If you have BlazeMeter credentials configured, check your dashboard:
    echo https://a.blazemeter.com/app/#/masters/projects
) else (
    echo.
    echo ========================================
    echo Test failed with error code: %errorlevel%
    echo ========================================
)

echo.
pause 