@echo off
REM ==============================================================================
REM LifeQuest - Script khoi chay 1-cham danh cho Do an Lap trinh Thiet bi Di dong
REM Khoa CNTT - Truong Dai hoc Cong nghe TP.HCM (HUTECH)
REM ==============================================================================

echo [1/3] Dang khoi dong Backend REST API va SQLite Database...
cd /d "%~dp0backend"
if not exist node_modules (
    echo Dang cai dat thu vien Backend...
    call npm install
)
start "LifeQuest Backend API (Port 3000)" cmd /k npm start

echo [2/3] Chuan bi moi truong Flutter...
cd /d "%~dp0"
call flutter pub get

echo [3/3] Dang khoi chay ung dung LifeQuest...
set DEV=%1
if "%DEV%"=="" (
    flutter run
) else (
    if "%2"=="" (
        flutter run -d %DEV%
    ) else (
        flutter run -d %DEV% --dart-define=API_BASE_URL=%2
    )
)
