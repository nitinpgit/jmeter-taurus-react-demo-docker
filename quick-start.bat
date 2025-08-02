@echo off
setlocal enabledelayedexpansion

echo === Jenkins Taurus Performance Testing - Quick Start ===
echo.

REM Check if Docker is installed
echo [INFO] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo [SUCCESS] Docker and Docker Compose are installed

REM Check if ports are available
echo [INFO] Checking if required ports are available...
set "unavailable_ports="
for %%p in (3000 5000 8080) do (
    netstat -an | find "%%p" | find "LISTENING" >nul 2>&1
    if not errorlevel 1 (
        if defined unavailable_ports (
            set "unavailable_ports=!unavailable_ports!, %%p"
        ) else (
            set "unavailable_ports=%%p"
        )
    )
)

if defined unavailable_ports (
    echo [WARNING] The following ports are already in use: !unavailable_ports!
    echo [WARNING] Please stop the services using these ports or modify the docker-compose file
    set /p "continue=Do you want to continue anyway? (y/N): "
    if /i not "!continue!"=="y" (
        pause
        exit /b 1
    )
) else (
    echo [SUCCESS] All required ports are available
)

REM Setup persistent data directories
echo [INFO] Setting up persistent data directories...

if not exist "jenkins-data" mkdir jenkins-data
if not exist "jenkins-data\home" mkdir jenkins-data\home
if not exist "jenkins-data\workspace" mkdir jenkins-data\workspace
if not exist "jenkins-data\test-results" mkdir jenkins-data\test-results

if not exist "app-data" mkdir app-data
if not exist "app-data\backend" mkdir app-data\backend
if not exist "app-data\frontend" mkdir app-data\frontend
if not exist "app-data\logs" mkdir app-data\logs

if not exist "test-data" mkdir test-data
if not exist "test-data\jmeter" mkdir test-data\jmeter
if not exist "test-data\taurus" mkdir test-data\taurus
if not exist "test-data\results" mkdir test-data\results

REM Create .gitkeep files
echo. > jenkins-data\.gitkeep
echo. > app-data\.gitkeep
echo. > test-data\.gitkeep

echo [SUCCESS] Persistent data directories created

REM Start the services
echo [INFO] Starting Docker services...

REM Stop any existing containers
docker-compose -f docker-compose-persistent.yml down --remove-orphans >nul 2>&1

REM Start services
docker-compose -f docker-compose-persistent.yml up -d

if errorlevel 1 (
    echo [ERROR] Failed to start Docker services
    pause
    exit /b 1
)

echo [SUCCESS] Docker services started

REM Wait for services to be ready
echo [INFO] Waiting for services to be ready...

REM Wait for Jenkins
echo [INFO] Waiting for Jenkins to start...
set "jenkins_ready=false"
for /l %%i in (1,1,60) do (
    curl -s http://localhost:8080 >nul 2>&1
    if not errorlevel 1 (
        set "jenkins_ready=true"
        goto :jenkins_ready
    )
    timeout /t 2 /nobreak >nul
)

:jenkins_ready
if "!jenkins_ready!"=="false" (
    echo [ERROR] Jenkins failed to start within 2 minutes
    docker-compose -f docker-compose-persistent.yml logs jenkins
    pause
    exit /b 1
)

echo [SUCCESS] Jenkins is ready

REM Wait for backend
echo [INFO] Waiting for backend to be ready...
set "backend_ready=false"
for /l %%i in (1,1,30) do (
    curl -s http://localhost:5000/api/health >nul 2>&1
    if not errorlevel 1 (
        set "backend_ready=true"
        goto :backend_ready
    )
    timeout /t 2 /nobreak >nul
)

:backend_ready
if "!backend_ready!"=="false" (
    echo [WARNING] Backend health check failed, but continuing...
) else (
    echo [SUCCESS] Backend is ready
)

REM Wait for frontend
echo [INFO] Waiting for frontend to be ready...
set "frontend_ready=false"
for /l %%i in (1,1,30) do (
    curl -s http://localhost:3000 >nul 2>&1
    if not errorlevel 1 (
        set "frontend_ready=true"
        goto :frontend_ready
    )
    timeout /t 2 /nobreak >nul
)

:frontend_ready
if "!frontend_ready!"=="false" (
    echo [WARNING] Frontend health check failed, but continuing...
) else (
    echo [SUCCESS] Frontend is ready
)

REM Display final information
echo.
echo === Setup Complete! ===
echo.
echo Services are now running:
echo   • Jenkins: http://localhost:8080
echo   • Frontend: http://localhost:3000
echo   • Backend API: http://localhost:5000
echo.
echo Next steps:
echo 1. Access Jenkins at http://localhost:8080
echo 2. Get the initial admin password:
echo    docker-compose -f docker-compose-persistent.yml logs jenkins
echo 3. Follow the Jenkins setup wizard
echo 4. Install required plugins (see JENKINS_SETUP_GUIDE.md)
echo 5. Create the freestyle job using jenkins-job-config.xml
echo.
echo Useful commands:
echo   • View logs: docker-compose -f docker-compose-persistent.yml logs [service]
echo   • Stop services: docker-compose -f docker-compose-persistent.yml down
echo   • Restart services: docker-compose -f docker-compose-persistent.yml restart
echo.
echo Data persistence:
echo   • Jenkins data: .\jenkins-data\
echo   • Application data: .\app-data\
echo   • Test data: .\test-data\
echo.
echo [SUCCESS] Setup completed successfully!
pause 