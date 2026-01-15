@echo off
:: Lanzador de HytaleServerSetup - XavierDevs
:: Solo haz doble clic en este archivo

echo ============================================================
echo        HYTALE SERVER SETUP - Iniciando instalador...
echo ============================================================
echo.

:: Verificar si es administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Solicitando permisos de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Ejecutar el script de PowerShell con permisos
powershell -ExecutionPolicy Bypass -File "%~dp0HytaleServerSetup.ps1"

pause
