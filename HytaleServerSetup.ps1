#Requires -RunAsAdministrator
# Script de instalacion del servidor de Hytale para Windows 11
# Autor: XavierDevs
# Version: 2.0 (Compatible)

param(
    [string]$ServerPath = "C:\HytaleServer",
    [int]$MinRAM = 4,
    [int]$MaxRAM = 4,
    [switch]$SkipOptional,
    [switch]$Unattended
)

# Colores
$ColorExito = "Green"
$ColorError = "Red"
$ColorInfo = "Cyan"
$ColorAdvertencia = "Yellow"

# ============================================================================
# FUNCIONES
# ============================================================================

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor $ColorInfo
    Write-Host "         HYTALE SERVER SETUP - Windows 11 Edition" -ForegroundColor $ColorInfo
    Write-Host "                     Por XavierDevs" -ForegroundColor $ColorInfo
    Write-Host "============================================================" -ForegroundColor $ColorInfo
    Write-Host ""
}

function Write-Step {
    param(
        [int]$StepNumber,
        [int]$TotalSteps,
        [string]$Message
    )
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor $ColorInfo
    Write-Host "  PASO $StepNumber de $TotalSteps - $Message" -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor $ColorInfo
}

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor $ColorExito
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "  [ERROR] $Message" -ForegroundColor $ColorError
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor $ColorInfo
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [AVISO] $Message" -ForegroundColor $ColorAdvertencia
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-JavaInstalled {
    try {
        $javaCmd = Get-Command java -ErrorAction SilentlyContinue
        if ($javaCmd) {
            $version = & java -version 2>&1
            if ($version[0] -match '"(\d+)') {
                return @{
                    Installed = $true
                    Version = $matches[1]
                }
            }
        }
    }
    catch { }
    return @{
        Installed = $false
        Version = $null
    }
}

function Test-ChocolateyInstalled {
    return $null -ne (Get-Command choco -ErrorAction SilentlyContinue)
}

function Test-GitInstalled {
    return $null -ne (Get-Command git -ErrorAction SilentlyContinue)
}

function Test-GradleInstalled {
    return $null -ne (Get-Command gradle -ErrorAction SilentlyContinue)
}

function Install-Chocolatey {
    Write-Info "Instalando Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) | Out-Null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Success "Chocolatey instalado correctamente"
        return $true
    }
    catch {
        Write-ErrorMsg "Error instalando Chocolatey: $($_.Exception.Message)"
        return $false
    }
}

function Install-JavaJDK {
    Write-Info "Instalando Java JDK 25 (Temurin)..."
    try {
        choco install temurin25 -y --force | Out-Null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $env:JAVA_HOME = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
        Write-Success "Java JDK 25 instalado correctamente"
        Write-Info "JAVA_HOME: $env:JAVA_HOME"
        return $true
    }
    catch {
        Write-ErrorMsg "Error instalando Java: $($_.Exception.Message)"
        return $false
    }
}

function Install-Gradle {
    Write-Info "Instalando Gradle 9.2.0..."
    try {
        choco install gradle --version=9.2.0 -y | Out-Null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Success "Gradle 9.2.0 instalado correctamente"
        return $true
    }
    catch {
        Write-ErrorMsg "Error instalando Gradle: $($_.Exception.Message)"
        return $false
    }
}

function Install-Git {
    Write-Info "Instalando Git..."
    try {
        choco install git -y | Out-Null
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Success "Git instalado correctamente"
        return $true
    }
    catch {
        Write-ErrorMsg "Error instalando Git: $($_.Exception.Message)"
        return $false
    }
}

function Get-HytaleGamePath {
    $hytalePath = Join-Path $env:APPDATA "Hytale\install\release\package\game\latest"
    if (Test-Path $hytalePath) {
        return $hytalePath
    }
    return $null
}

function Copy-ServerFiles {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )
    try {
        $serverSource = Join-Path $SourcePath "Server"
        $serverDest = Join-Path $DestinationPath "Server"
        
        Write-Info "Copiando carpeta Server..."
        Copy-Item -Path $serverSource -Destination $serverDest -Recurse -Force
        Write-Success "Carpeta Server copiada"
        
        $assetsSource = Join-Path $SourcePath "Assets.zip"
        $assetsDest = Join-Path $DestinationPath "Assets.zip"
        
        Write-Info "Copiando Assets.zip (esto puede tardar, son ~3.2 GB)..."
        Copy-Item -Path $assetsSource -Destination $assetsDest -Force
        Write-Success "Assets.zip copiado"
        
        return $true
    }
    catch {
        Write-ErrorMsg "Error copiando archivos: $($_.Exception.Message)"
        return $false
    }
}

function New-StartScript {
    param(
        [string]$ServerPath,
        [int]$MinRAM,
        [int]$MaxRAM
    )
    
    $scriptContent = @"
@echo off
title Hytale Server - Desarrollo Local
color 0A
echo.
echo ============================================================
echo           HYTALE SERVER - Iniciando...
echo ============================================================
echo.
cd Server
echo [INFO] Configuracion de memoria: $($MinRAM)GB min / $($MaxRAM)GB max
echo [INFO] Iniciando servidor...
echo.
java -Xms$($MinRAM)G -Xmx$($MaxRAM)G -jar HytaleServer.jar --assets ..\Assets.zip --disable-sentry
echo.
echo [INFO] Servidor detenido.
pause
"@
    
    $scriptPath = Join-Path $ServerPath "start-server.bat"
    
    try {
        $scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII -Force
        Write-Success "Script de inicio creado: $scriptPath"
        return $true
    }
    catch {
        Write-ErrorMsg "Error creando script: $($_.Exception.Message)"
        return $false
    }
}

function New-QuickAuthScript {
    param([string]$ServerPath)
    
    $scriptContent = @"
@echo off
title Hytale Server - Autenticacion
color 0E
echo.
echo ============================================================
echo              AUTENTICACION DEL SERVIDOR
echo ============================================================
echo.
echo INSTRUCCIONES:
echo.
echo 1. Primero, inicia el servidor con start-server.bat
echo 2. Cuando el servidor este corriendo, escribe: /auth login device
echo 3. Copia el codigo que aparece
echo 4. Presiona cualquier tecla para abrir la pagina de autenticacion
echo 5. Ingresa el codigo en la pagina web
echo.
pause
start https://accounts.hytale.com/device
echo.
echo [INFO] Pagina de autenticacion abierta en tu navegador.
echo [INFO] Ingresa el codigo del servidor y autoriza.
echo.
pause
"@
    
    $scriptPath = Join-Path $ServerPath "autenticar-servidor.bat"
    
    try {
        $scriptContent | Out-File -FilePath $scriptPath -Encoding ASCII -Force
        Write-Success "Script de autenticacion creado: $scriptPath"
        return $true
    }
    catch {
        Write-ErrorMsg "Error creando script: $($_.Exception.Message)"
        return $false
    }
}

function Show-Summary {
    param([string]$ServerPath)
    
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor $ColorExito
    Write-Host "           INSTALACION COMPLETADA" -ForegroundColor $ColorExito
    Write-Host "============================================================" -ForegroundColor $ColorExito
    Write-Host ""
    Write-Host "  Ubicacion del servidor: $ServerPath" -ForegroundColor White
    Write-Host ""
    Write-Host "  Scripts creados:" -ForegroundColor White
    Write-Host "    - start-server.bat        (Inicia el servidor)" -ForegroundColor White
    Write-Host "    - autenticar-servidor.bat (Ayuda con la autenticacion)" -ForegroundColor White
    Write-Host ""
    Write-Host "  PASOS SIGUIENTES:" -ForegroundColor $ColorAdvertencia
    Write-Host "    1. Abre la carpeta: $ServerPath" -ForegroundColor White
    Write-Host "    2. Ejecuta: start-server.bat" -ForegroundColor White
    Write-Host "    3. Espera a que cargue completamente" -ForegroundColor White
    Write-Host "    4. Escribe en la consola: /auth login device" -ForegroundColor White
    Write-Host "    5. Sigue las instrucciones de autenticacion" -ForegroundColor White
    Write-Host "    6. Conectate desde Hytale a localhost:5520" -ForegroundColor White
    Write-Host ""
    Write-Host "  COMANDOS UTILES:" -ForegroundColor $ColorInfo
    Write-Host "    /stop              - Detiene el servidor" -ForegroundColor White
    Write-Host "    /list              - Lista jugadores conectados" -ForegroundColor White
    Write-Host "    /gamemode creative - Cambia a modo creativo" -ForegroundColor White
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor $ColorExito
}

function Request-UserConfirmation {
    param([string]$Message)
    
    if ($Unattended) {
        return $true
    }
    
    Write-Host ""
    Write-Host "  $Message (S/N): " -ForegroundColor $ColorAdvertencia -NoNewline
    $response = Read-Host
    return @("S", "s", "Si", "si", "SI", "Y", "y", "Yes", "yes") -contains $response
}

# ============================================================================
# SCRIPT PRINCIPAL
# ============================================================================

Write-Banner

# Verificar administrador
if (-not (Test-Administrator)) {
    Write-ErrorMsg "Este script debe ejecutarse como Administrador."
    Write-Info "Haz clic derecho en PowerShell y selecciona 'Ejecutar como administrador'"
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Success "Ejecutando como Administrador"

$totalSteps = if ($SkipOptional) { 4 } else { 6 }
$currentStep = 0

# PASO 1: Chocolatey
$currentStep++
Write-Step -StepNumber $currentStep -TotalSteps $totalSteps -Message "Verificar Chocolatey"

if (Test-ChocolateyInstalled) {
    Write-Success "Chocolatey ya esta instalado"
}
else {
    Write-Warn "Chocolatey no esta instalado"
    if (Request-UserConfirmation "Deseas instalar Chocolatey?") {
        if (-not (Install-Chocolatey)) {
            Write-ErrorMsg "No se pudo instalar Chocolatey. Abortando."
            exit 1
        }
    }
    else {
        Write-ErrorMsg "Chocolatey es necesario. Abortando."
        exit 1
    }
}

# PASO 2: Java
$currentStep++
Write-Step -StepNumber $currentStep -TotalSteps $totalSteps -Message "Verificar Java JDK 25"

$javaStatus = Test-JavaInstalled

if ($javaStatus.Installed) {
    Write-Success "Java esta instalado (version $($javaStatus.Version))"
    if ([int]$javaStatus.Version -lt 25) {
        Write-Warn "Se recomienda Java 25 o superior. Tienes la version $($javaStatus.Version)"
        if (Request-UserConfirmation "Deseas instalar Java 25?") {
            Install-JavaJDK
        }
    }
}
else {
    Write-Warn "Java no esta instalado"
    if (Request-UserConfirmation "Deseas instalar Java JDK 25?") {
        if (-not (Install-JavaJDK)) {
            Write-ErrorMsg "No se pudo instalar Java. Abortando."
            exit 1
        }
    }
    else {
        Write-ErrorMsg "Java es necesario. Abortando."
        exit 1
    }
}

# PASOS 3 y 4: Gradle y Git (Opcional)
if (-not $SkipOptional) {
    $currentStep++
    Write-Step -StepNumber $currentStep -TotalSteps $totalSteps -Message "Verificar Gradle (opcional)"
    
    if (Test-GradleInstalled) {
        Write-Success "Gradle ya esta instalado"
    }
    else {
        Write-Info "Gradle es opcional - solo para desarrollo de plugins"
        if (Request-UserConfirmation "Deseas instalar Gradle?") {
            Install-Gradle
        }
        else {
            Write-Info "Omitiendo Gradle"
        }
    }
    
    $currentStep++
    Write-Step -StepNumber $currentStep -TotalSteps $totalSteps -Message "Verificar Git (opcional)"
    
    if (Test-GitInstalled) {
        Write-Success "Git ya esta instalado"
    }
    else {
        Write-Info "Git es opcional - para clonar repositorios"
        if (Request-UserConfirmation "Deseas instalar Git?") {
            Install-Git
        }
        else {
            Write-Info "Omitiendo Git"
        }
    }
}

# PASO 5: Archivos del servidor
$currentStep++
Write-Step -StepNumber $currentStep -TotalSteps $totalSteps -Message "Configurar archivos del servidor"

$hytalePath = Get-HytaleGamePath

if ($hytalePath) {
    Write-Success "Hytale encontrado en: $hytalePath"
    
    $serverFolder = Join-Path $hytalePath "Server"
    $assetsFile = Join-Path $hytalePath "Assets.zip"
    
    $serverExists = Test-Path $serverFolder
    $assetsExists = Test-Path $assetsFile
    
    if ($serverExists -and $assetsExists) {
        Write-Success "Archivos del servidor encontrados"
        
        if (-not (Test-Path $ServerPath)) {
            Write-Info "Creando carpeta: $ServerPath"
            New-Item -Path $ServerPath -ItemType Directory -Force | Out-Null
        }
        
        if (Request-UserConfirmation "Copiar archivos del servidor a $ServerPath ?") {
            Copy-ServerFiles -SourcePath $hytalePath -DestinationPath $ServerPath
        }
    }
    else {
        Write-Warn "No se encontraron todos los archivos necesarios"
        if (-not $serverExists) { Write-ErrorMsg "Falta: Carpeta Server" }
        if (-not $assetsExists) { Write-ErrorMsg "Falta: Assets.zip" }
        Write-Info "Asegurate de haber iniciado Hytale al menos una vez"
    }
}
else {
    Write-Warn "No se encontro la instalacion de Hytale"
    Write-Info "Ruta esperada: %APPDATA%\Hytale\install\release\package\game\latest"
    Write-Info ""
    Write-Info "Opciones:"
    Write-Info "  1. Instala Hytale e inicialo al menos una vez"
    Write-Info "  2. Usa el Hytale Downloader CLI"
    
    if (Request-UserConfirmation "Crear estructura de carpetas vacia?") {
        if (-not (Test-Path $ServerPath)) {
            New-Item -Path $ServerPath -ItemType Directory -Force | Out-Null
            New-Item -Path (Join-Path $ServerPath "Server") -ItemType Directory -Force | Out-Null
            Write-Success "Estructura de carpetas creada"
            Write-Info "Deberas copiar manualmente Server/ y Assets.zip"
        }
    }
}

# PASO 6: Scripts de inicio
$currentStep++
Write-Step -StepNumber $currentStep -TotalSteps $totalSteps -Message "Crear scripts de inicio"

if (Test-Path $ServerPath) {
    New-StartScript -ServerPath $ServerPath -MinRAM $MinRAM -MaxRAM $MaxRAM
    New-QuickAuthScript -ServerPath $ServerPath
}
else {
    Write-Warn "No se crearon los scripts porque la carpeta no existe"
}

# Resumen
Show-Summary -ServerPath $ServerPath

if (Request-UserConfirmation "Abrir la carpeta del servidor?") {
    if (Test-Path $ServerPath) {
        Start-Process explorer.exe -ArgumentList $ServerPath
    }
}

Write-Host ""
Write-Host "Gracias por usar el instalador de Hytale Server!" -ForegroundColor $ColorExito
Write-Host "Creado por XavierDevs" -ForegroundColor $ColorInfo
Write-Host ""
