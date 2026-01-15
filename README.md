# Hytale Server Setup (Windows 11) 🎮

![Version](https://img.shields.io/badge/version-2.1-blue) ![Platform](https://img.shields.io/badge/platform-Windows_11-0078D6) ![License](https://img.shields.io/badge/license-MIT-green)

Script de PowerShell automatizado para configurar un servidor de desarrollo local de **Hytale** en Windows 11.

📺 Video tutorial en mi canal: [**XaviDevs**](https://www.youtube.com/@XaviDevs)

---

## 🚀 Características

- ✅ Instalación automática de Java 25 (Temurin), Git, Gradle y Chocolatey
- ✅ Copia automática de archivos del servidor desde tu instalación de Hytale
- ✅ Genera scripts de inicio y autenticación

## 📋 Requisitos

- Windows 10 o 11
- Hytale instalado (para copiar los archivos del servidor)

## 🛠️ Instalación (2 pasos)

### Paso 1: Descargar
Descarga todos los archivos o clona el repositorio:
```bash
git clone https://github.com/TU_USUARIO/hytale-server-setup.git
```

### Paso 2: Ejecutar
**Haz doble clic en `Instalar-Servidor.bat`** y sigue las instrucciones.

> Windows te pedirá permisos 2 o 3 veces, dale "Ejecutar" en ambas.

---

## 🎮 Después de Instalar

### 1. Iniciar el servidor
Ve a `C:\HytaleServer` y ejecuta `start-server.bat`

### 2. Autenticar (solo la primera vez)
```
/auth login device
```
Copia el código, ve a https://accounts.hytale.com/device e ingresa el código.

### 3. Conectarte desde Hytale

| Campo | Valor |
|-------|-------|
| **Dirección** | `localhost:5520` |
| **Puerto** | `5520` (ya incluido) |

### 4. Comandos útiles en el juego
| Comando | Descripción |
|---------|-------------|
| `/gamemode creative` | Modo creativo |
| `/gamemode survival` | Modo supervivencia |
| `/tp 0 100 0` | Teletransporte |
| `/stop` | Detener servidor |

---

## 📁 Archivos del Proyecto

| Archivo | Descripción |
|---------|-------------|
| `Instalar-Servidor.bat` | 🟢 **Ejecuta esto para instalar** |
| `HytaleServerSetup.ps1` | Script principal |

---

## ⚙️ Opciones Avanzadas (Opcional)

```powershell
# Instalación con más RAM (si tienes 16GB+)
.\HytaleServerSetup.ps1 -MinRAM 8 -MaxRAM 8

# Instalación rápida (sin Git ni Gradle)
.\HytaleServerSetup.ps1 -SkipOptional

```

---

## 🤝 Contribuir

1. Haz un **Fork** del proyecto
2. Crea una rama (`git checkout -b feature/MiMejora`)
3. Commit (`git commit -m 'Agregado: nueva función'`)
4. Push (`git push origin feature/MiMejora`)
5. Abre un **Pull Request**

## ⚖️ Aviso Legal

Este proyecto **no está afiliado con Hypixel Studios ni Riot Games**.
Hytale™ es marca registrada de Hypixel Studios.

## 📄 Licencia

MIT License - Libre para usar, modificar y distribuir.

---

Creado con ❤️ por [XavierDevs](https://www.youtube.com/@XaviDevs)
