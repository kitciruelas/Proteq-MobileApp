@echo off
echo ========================================
echo Proteq Backend Setup Script
echo ========================================
echo.

echo Checking XAMPP installation...
if not exist "C:\xampp\xampp-control.exe" (
    echo ERROR: XAMPP not found in C:\xampp\
    echo Please install XAMPP from https://www.apachefriends.org/
    pause
    exit /b 1
)

echo XAMPP found! Starting services...
echo.

echo Starting Apache...
start /B "C:\xampp\xampp-control.exe"
timeout /t 3 /nobreak >nul

echo Starting MySQL...
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo Manual Steps Required:
echo ========================================
echo.
echo 1. In XAMPP Control Panel:
echo    - Click "Start" for Apache
echo    - Click "Start" for MySQL
echo    - Wait for both to show green status
echo.
echo 2. Open phpMyAdmin:
echo    - Go to: http://localhost/phpmyadmin
echo    - Create database: proteq_db
echo    - Import file: backend\server\database\proteq_db.sql
echo.
echo 3. Copy backend files:
echo    - Copy backend\server\ to C:\xampp\htdocs\proteq-backend\
echo.
echo 4. Test the setup:
echo    - Visit: http://localhost/proteq-backend/api/diagnostic.php
echo    - Visit: http://localhost/proteq-backend/api/test.php
echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Your API will be available at:
echo http://localhost/proteq-backend/api/
echo.
echo Press any key to open XAMPP Control Panel...
pause
start "C:\xampp\xampp-control.exe" 