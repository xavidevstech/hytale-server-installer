# Hytale Server Setup (Windows 11) 🎮

![Version](https://img.shields.io/badge/version-2.0-blue) ![Platform](https://img.shields.io/badge/platform-Windows_11-win) ![License](https://img.shields.io/badge/license-MIT-green)

Un script de PowerShell automatizado para configurar, instalar y lanzar un servidor de desarrollo local de **Hytale** en Windows 11.

Este proyecto fue presentado en mi canal de YouTube: [**XaviDevs**](https://www.youtube.com/@XaviDevs).

## 🚀 Características

* **Verificación automática:** Comprueba si tienes Java 25 (Temurin), Git y Chocolatey.
* **Instalación desatendida:** Instala las dependencias necesarias si faltan.
* **Configuración del entorno:** Copia los archivos `Server` y `Assets` desde tu instalación local de Hytale.
* **Scripts de utilidad:** Genera automáticamente `start-server.bat` y scripts de autenticación.

## 📋 Requisitos Previos

* Windows 10 o 11.
* PowerShell ejecutado como **Administrador**.
* Tener acceso a la beta/juego de Hytale instalado localmente.

## 🛠️ Cómo usarlo

1.  Descarga el archivo `HytaleServerSetup.ps1`.
2.  Haz clic derecho en el archivo y selecciona **"Ejecutar con PowerShell"**.
3.  Sigue las instrucciones en pantalla.

O ejecútalo desde la terminal:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; .\HytaleServerSetup.ps1


## 🤝 Cómo Contribuir

¡Las contribuciones son bienvenidas! Este proyecto busca ser la herramienta estándar para la comunidad hispana de Hytale. Si quieres mejorar el código:

1.  Haz un **Fork** del proyecto.
2.  Crea una rama nueva (`git checkout -b feature/NuevaMejora`).
3.  Haz tus cambios y confirma (`git commit -m 'Mejora: Agregado soporte para X'`).
4.  Haz Push (`git push origin feature/NuevaMejora`).
5.  Abre un **Pull Request**.

## ⚖️ Aviso Legal (Disclaimer)

Este proyecto es una herramienta no oficial desarrollada por la comunidad y **no está afiliada, respaldada ni asociada de ninguna manera con Hypixel Studios ni con Riot Games**.

Hytale™ es una marca registrada de Hypixel Studios.

## 📄 Licencia

Este proyecto se distribuye bajo la licencia **MIT**. Eres libre de usarlo, modificarlo y distribuirlo, siempre que mantengas la atribución al autor original.
