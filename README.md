# Laboratorio: Black Hat Bash - Parte 3

**Integrantes del Grupo:**
* Diego Veloz
* Flavio Granizo
* Alex Gaibor

**Materia:** Seguridad en Sistemas Operativos  
**Universidad:** Universidad Internacional del Ecuador (UIDE)
## PAR1 
Modification Process (Cubic Environment)
To achieve the customization of this distribution, we entered the chroot environment using the Cubic tool and executed the following commands as root user.

1. Base System Update
Before injecting the packages, the Ubuntu repositories were synchronized:

Bash
apt update && apt upgrade -y
2. Tool Injection (Actual Modifications)
The three packages required for the project were installed, justifying their use in the Live environment:

Java (Development Environment): Vital for compiling and executing object-oriented projects directly from memory.

Bash
apt install default-jdk -y
Hashcat (Auditing): A brute-force tool injected to perform security tests on the system.

Bash
apt install hashcat -y
Neovim (Text Editing): A replacement for the standard editor, necessary for editing code and configuration files without depending on a graphical interface.

Bash
apt install neovim -y
3. Persistence Configuration (/etc/skel)
To ensure that any new user created in the distribution inherits the work structure, the system skeleton was modified by creating default directories:

Bash
mkdir -p /etc/skel/Proyectos
mkdir -p /etc/skel/Laboratorio
(Note: These directories are now automatically copied to the /home folder of every new user).
https://youtu.be/NhTggZ6UM4I
---
## PART 2.


## PART 3.A — Lab up and running

### 1. Tabla de Arquitectura del Laboratorio
Mapeo de los contenedores desplegados, sus nombres, roles y asignación de direccionamiento IP dentro de las dos redes aisladas creadas por Docker Compose:

| Máquina (Contenedor) | Red Pública (172.16.10.0/24) | Red Corporativa (10.1.0.0/24) | Rol / Función |
| :--- | :--- | :--- | :--- |
| **p-web-01** | 172.16.10.10 | N/A | Servidor Web Público Primario |
| **p-web-02** | 172.16.10.11 | N/A | Servidor Web Público Secundario |
| **p-ftp-01** | 172.16.10.12 | N/A | Servidor de Transferencia de Archivos (FTP) |
| **p-jumpbox-01** | 172.16.10.13 | 10.1.0.13 (Dual-Homed) | Bastión de acceso / Puente entre redes |
| **c-db-01** | N/A | 10.1.0.10 | Base de Datos Corporativa (Producción) |
| **c-db-02** | N/A | 10.1.0.11 | Base de Datos Corporativa (Réplica) |
| **c-redis-01** | N/A | 10.1.0.12 | Servidor de Caché en memoria interno |
| **c-backup-01** | N/A | 10.1.0.14 | Servidor de Respaldos Internos |

### 2. Diagrama de Red (Two-Network Diagram)
[ INTERNET / RED ATACANTE (Debian Host) ]
                    │
                    ▼

┌───────────────────────────────────────────────┐
│ RED PÚBLICA (br_public) - 172.16.10.0/24      │
└──────┬────────────┬────────────┬──────────────┘
│            │            │
▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐       ┌──────────────┐
│ p-web-01 │ │ p-web-02 │ │ p-ftp-01 │       │ p-jumpbox-01 │ (Puente)
└──────────┘ └──────────┘ └──────────┘       └──────┬───────┘
│
┌─────────────────────────────────────────────────────┘
│ RED CORPORATIVA (br_corporate) - 10.1.0.0/24

└──────┬────────────┬────────────┬──────────────┘
│            │            │
▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ c-db-01  │ │ c-db-02  │ │c-redis-01│
└──────────┘ └──────────┘ └──────────┘
### 3. Evidencias del Despliegue
* Despliegue completado de forma íntegra tras la expansión del contenedor criptográfico y la asignación dinámica de volúmenes lógicos con LVM.
* Comandos validados mediante capturas del laboratorio (`make deploy`, `make test`, `docker ps` y `ip addr`).

---

## PART 3.B — Hacking Technique: Advanced Port Scanning & Service Fingerprinting

### 1. ¿Qué hace la técnica?
Se utilizó la herramienta **Nmap** con la bandera de escaneo completo de puertos (`-p-`) y detección activa de versiones (`-sV`). Esta técnica interactúa con los servicios enviando sondas de datos para capturar sus banners e identificar con precisión el software de backend, frameworks y versiones exactas que se están ejecutando (Fingerprinting).

### 2. ¿Por qué funciona en este laboratorio?
Funciona debido a que el host atacante se encuentra conectado directamente a la interfaz puente de la red pública (`br_public: 172.16.10.1`). Al no existir un firewall intermedio bloqueando el tráfico dentro del segmento, Nmap puede escanear libremente las IPs asignadas a los contenedores y forzar a las aplicaciones a responder revelando su configuración interna.

### 3. Interpretación Técnica de los Resultados Obtenidos
El análisis avanzado de Nmap sobre el perímetro público arrojó datos críticos que revelan malas configuraciones del entorno simulado:

* **p-web-01 (172.16.10.10):** Se descubrió que el servidor web expone un puerto no estándar: **8081/TCP**. El fingerprinting identificó de forma exacta que corre un servidor **Werkzeug httpd 3.0.1 sobre Python 3.12.3 (Flask)**. Si el modo de depuración (Debug Mode) se encuentra activo por omisión, este entorno permitiría la ejecución remota de código (RCE) a través de su consola interactiva.
* **p-ftp-01 (172.16.10.12):** Expone un servicio web en el puerto **80/TCP** corriendo un servidor **Apache httpd 2.4.57 sobre Debian**, abriendo un vector secundario de enumeración de vulnerabilidades conocidas (CVEs).
