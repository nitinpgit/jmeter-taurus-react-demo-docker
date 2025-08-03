@echo off
echo ========================================
echo JMeter Test Runner (Local Machine)
echo ========================================
echo.

REM Check if JMeter is installed
where jmeter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: JMeter is not installed or not in PATH
    echo Please install JMeter from: https://jmeter.apache.org/download_jmeter.cgi
    echo Add JMeter bin directory to your PATH
    pause
    exit /b 1
)

echo JMeter found at: 
where jmeter
echo.

REM Set JMeter home if not set
if "%JMETER_HOME%"=="" (
    echo Setting JMETER_HOME to current directory
    set JMETER_HOME=%~dp0
)

echo Available JMeter test files:
echo.
echo 1. get-quick-message.jmx
echo 2. get-delayed-response.jmx
echo 3. get-health-check.jmx
echo 4. post-create-data.jmx
echo 5. put-update-user.jmx
echo 6. delete-user.jmx
echo 7. get-search-with-parameter.jmx
echo 8. test-plan.jmx (runs all tests)
echo.

set /p choice="Enter test number (1-8) or press Enter for quick message test: "

if "%choice%"=="" set choice=1

if "%choice%"=="1" (
    set TEST_FILE=jmeter/localhost3000/get-quick-message.jmx
    set TEST_NAME=Quick Message Test
) else if "%choice%"=="2" (
    set TEST_FILE=jmeter/localhost3000/get-delayed-response.jmx
    set TEST_NAME=Delayed Response Test
) else if "%choice%"=="3" (
    set TEST_FILE=jmeter/localhost3000/get-health-check.jmx
    set TEST_NAME=Health Check Test
) else if "%choice%"=="4" (
    set TEST_FILE=jmeter/localhost3000/post-create-data.jmx
    set TEST_NAME=Create Data Test
) else if "%choice%"=="5" (
    set TEST_FILE=jmeter/localhost3000/put-update-user.jmx
    set TEST_NAME=Update User Test
) else if "%choice%"=="6" (
    set TEST_FILE=jmeter/localhost3000/delete-user.jmx
    set TEST_NAME=Delete User Test
) else if "%choice%"=="7" (
    set TEST_FILE=jmeter/localhost3000/get-search-with-parameter.jmx
    set TEST_NAME=Search with Parameter Test
) else if "%choice%"=="8" (
    set TEST_FILE=jmeter/test-plan.jmx
    set TEST_NAME=Complete Test Plan
) else (
    echo Invalid choice. Using quick message test.
    set TEST_FILE=jmeter/localhost3000/get-quick-message.jmx
    set TEST_NAME=Quick Message Test
)

echo.
echo Running: %TEST_NAME%
echo Test file: %TEST_FILE%
echo.

REM Create results directory
if not exist "jmeter-results" mkdir jmeter-results

REM Run JMeter test
echo Starting JMeter test...
jmeter -n -t "%TEST_FILE%" -l "jmeter-results\results_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.jtl" -e -o "jmeter-results\html-report_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Test completed successfully!
    echo ========================================
    echo Results saved to: jmeter-results\
    echo HTML report generated in: jmeter-results\html-report_*
    echo.
    echo Opening HTML report...
    start "" "jmeter-results\html-report_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%\index.html"
) else (
    echo.
    echo ========================================
    echo Test failed with error code: %errorlevel%
    echo ========================================
)

echo.
pause 