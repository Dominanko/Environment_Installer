# Environment Installer  

Easily install popular Linux desktop environments (GNOME, KDE, XFCE, LXDE, Cinnamon, MATE) on multiple distributions using one script.  
Supports **Ubuntu/Debian**, **Arch**, **Fedora**, **openSUSE**, and **Alpine**.  

All installs are logged to `~/de-installer.log` for troubleshooting.  

---

## Quick Start  

Run directly without cloning:  

```bash
curl -fsSL https://raw.githubusercontent.com/Dominanko/Environment_Installer/main/Environment_Installer.sh | bash
```

Or clone manually:  

```bash
git clone https://github.com/Dominanko/Environment_Installer.git
cd Environment_Installer
chmod +x Environment_Installer.sh
./Environment_Installer.sh
```

---

## Usage  

### Interactive Menu  
Simply run with no arguments:  
```bash
./Environment_Installer.sh
```
You’ll get a menu like:  
```
1) Install GNOME
2) Install KDE Plasma
3) Install XFCE
4) Install LXDE
5) Install Cinnamon
6) Install MATE
7) Exit
```

### Direct Install Flags  
Skip the menu and install directly:  
```bash
./Environment_Installer.sh --gnome
./Environment_Installer.sh --kde
./Environment_Installer.sh --xfce
./Environment_Installer.sh --lxde
./Environment_Installer.sh --cinnamon
./Environment_Installer.sh --mate
```

### Help  
```bash
./Environment_Installer.sh --help
```

---

## Supported Distributions  

- **Ubuntu / Debian** (APT)  
- **Arch Linux** (pacman)  
- **Fedora** (dnf groupinstall)  
- **openSUSE** (zypper patterns)  
- **Alpine Linux** (apk, may require community/testing repos)  

---

## After Installation  

- Reboot your system.  
- At login, select your new **desktop environment** from the display manager.  

👉 Alpine users: If installation fails, enable `community` and `testing` repositories in `/etc/apk/repositories`.  

---

## Examples  

Install **XFCE** directly:  
```bash
./Environment_Installer.sh --xfce
```

Run menu installer:  
```bash
./Environment_Installer.sh
```

---

## Notes  

- All actions are logged to `~/de-installer.log`  
- Script will detect your distro and package manager automatically  
- Uninstall is **not automated** (depends on distro)  
