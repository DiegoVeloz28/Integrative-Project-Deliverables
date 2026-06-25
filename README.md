# Laboratorio: Black Hat Bash - Parte 3

**Integrantes del Grupo:**
* Diego Veloz
* Flavio Granizo
* Alex Gaibor

**Materia:** Seguridad en Sistemas Operativos  
**Universidad:** Universidad Internacional del Ecuador (UIDE)
## PART1 
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

ISO:
https://drive.google.com/file/d/1slqoS02NVKCfW4oIoUoeFjIgODWpP4G2/view?usp=sharing
---
## PART 2.
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



Technical Explanation of Network Segmentation and Attack Vectors

The lab design implements a *Defense in Depth* strategy by emulating the perimeter and internal infrastructure of a real organization using two completely isolated network segments:

*Perimeter Zone / DMZ (br_public - 172.16.10.0/24):* This segment simulates the company's public face exposed to the Internet (Attacker Network / Debian Host). It hosts the services for direct interaction with external users (p-web-01, p-web-02, and p-ftp-01). Lacking restrictive host-level firewalls within the Docker bridge, it allows for direct enumeration and service fingerprinting using tools like Nmap.

*Perimeter Zone / DMZ (br_public - 172.16.10.0/24):* * *Internal Corporate Zone (br_corporate - 10.1.0.0/24):* High-security segment that protects critical production assets (databases c-db-01, c-db-02, and the cache server c-redis-01). These machines have no port mapping to the attacking host or internet access, making them completely invisible and inaccessible from the external perimeter during the initial reconnaissance phase.

* *Access Pivot / Bastion (p-jumpbox-01):* Designed using a *Dual-Homed* architecture, it is the only container simultaneously connected to both Docker Compose networks. It acts as the only legitimate bridge for transition and control, requiring any interaction or administration with the corporate network to first compromise or authenticate through this intermediate node (pivoting techniques).

## PART 3.A — Lab up and running

### 1. Lab Architecture Table
Mapping of deployed containers, their names, roles, and IP address assignment within the two isolated networks created by Docker Compose:

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
### 3. Deployment Evidence
* Deployment fully completed after expanding the cryptographic container and dynamically allocating logical volumes with LVM.

* Commands validated through lab screenshots (`make deploy`, `make test`, `docker ps`, and `ip addr`).

---

## PART 3.B — Hacking Technique: Advanced Port Scanning & Service Fingerprinting
### 1. What does the technique do?
The **Nmap** tool was used with the full port scan flag (`-p-`) and active version detection (`-sV`). This technique interacts with services by sending data probes to capture their banners and accurately identify the backend software, frameworks, and exact versions being run (fingerprinting).

### 2. Why does it work in this lab?
It works because the attacking host is directly connected to the public network's bridge interface (`br_public: 172.16.10.1`). Since there is no intermediate firewall blocking traffic within the segment, Nmap can freely scan the IPs assigned to the containers and force the applications to respond, revealing their internal configuration.

### 3. Technical Interpretation of the Results Obtained
Advanced Nmap analysis of the public perimeter yielded critical data revealing misconfigurations in the simulated environment:

* **p-web-01 (172.16.10.10):** The web server was found to be exposing a non-standard port: **8081/TCP**. Fingerprinting precisely identified that it is running a **Werkzeug httpd 3.0.1 server on Python 3.12.3 (Flask)**. If Debug Mode is enabled by default, this environment would allow remote code execution (RCE) through its interactive console.

* * **p-ftp-01 (172.16.10.12):** Exposes a web service on port **80/TCP** running an **Apache httpd 2.4.57 server on Debian**, opening a secondary vector for enumerating known vulnerabilities (CVEs).