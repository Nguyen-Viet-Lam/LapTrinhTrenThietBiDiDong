@echo off
REM Chay backend (cua so rieng) roi chay app tren emulator/Chrome.
REM Dung: chay_local.bat            -> app tren thiet bi dang co (emulator)
REM       chay_local.bat chrome     -> app tren Chrome
REM Dien thoai that: chay_local.bat <device-id> http://<IP-may>:3000/api
cd /d "%~dp0backend"
if not exist node_modules call npm install
start "LifeQuest API" cmd /k npm start
cd /d "%~dp0"
set DEV=%1
if "%DEV%"=="" set DEV=emulator-5554
if "%2"=="" (flutter run -d %DEV%) else (flutter run -d %DEV% --dart-define=API_BASE_URL=%2)
