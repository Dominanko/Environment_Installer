#!/bin/bash
# Desktop Environment Installer Menu with Error Handling and Multi-Distro Support

LOGFILE="$HOME/de-installer.log"
trap "echo -e '\nExiting...'; exit 0" SIGINT

SUDO_CMD=""
[[ $EUID -ne 0 ]] && SUDO_CMD="sudo"

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
        VERSION_ID=${VERSION_ID:-unknown}
    else
        echo "Cannot detect Linux distribution."
        exit 1
    fi
}

check_root_or_sudo() {
    if [[ $EUID -ne 0 ]] && ! command -v sudo &>/dev/null; then
        echo "Please run as root or install sudo."
        exit 1
    fi
}

check_pkg_manager() {
    case $DISTRO in
        ubuntu|debian)
            command -v apt-get &>/dev/null || { echo "apt-get not found."; exit 1; }
            ;;
        arch)
            command -v pacman &>/dev/null || { echo "pacman not found."; exit 1; }
            ;;
        fedora)
            command -v dnf &>/dev/null || { echo "dnf not found."; exit 1; }
            ;;
        opensuse*|suse)
            command -v zypper &>/dev/null || { echo "zypper not found."; exit 1; }
            ;;
        alpine)
            command -v apk &>/dev/null || { echo "apk not found."; exit 1; }
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

run_cmd() {
    echo "==== Starting $(date) ====" >>"$LOGFILE"
    echo "Running: $*" >>"$LOGFILE"
    "$@" >>"$LOGFILE" 2>&1
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Error: Command failed: $*"
        echo "See $LOGFILE for details."
        exit $status
    fi
}

install_pkg() {
    case $DISTRO in
        ubuntu|debian)
            run_cmd $SUDO_CMD apt-get install -y -q "$@"
            ;;
        arch)
            run_cmd $SUDO_CMD pacman -Sy --noconfirm "$@"
            ;;
        fedora)
            run_cmd $SUDO_CMD dnf install -y --quiet "$@"
            ;;
        opensuse*|suse)
            run_cmd $SUDO_CMD zypper install -y --quiet "$@"
            ;;
        alpine)
            run_cmd $SUDO_CMD apk add "$@"
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
}

install_group() {
    # Only for dnf group installs
    if [[ $DISTRO == "fedora" ]]; then
        run_cmd $SUDO_CMD dnf group install -y --quiet "$@"
    fi
}

install_gnome() {
    echo "Installing GNOME..."
    case $DISTRO in
        ubuntu|debian)
            install_pkg gnome-session gnome-shell
            ;;
        arch)
            install_pkg gnome gnome-extra
            ;;
        fedora)
            if ! dnf group list -v | grep -q "GNOME Desktop"; then
                install_pkg gnome-shell
            else
                install_group "GNOME Desktop"
            fi
            ;;
        opensuse*|suse)
            if zypper -h | grep -q patterns; then
                install_pkg patterns-gnome-gnome
            else
                install_pkg gnome-shell
            fi
            ;;
        alpine)
            echo "Warning: Desktop environments in Alpine may require community/testing repos."
            install_pkg gnome || echo "Try enabling community/testing repositories."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    echo "GNOME installed."
    post_install
}

install_kde() {
    echo "Installing KDE Plasma..."
    case $DISTRO in
        ubuntu|debian)
            install_pkg kde-plasma-desktop
            ;;
        arch)
            install_pkg plasma kde-applications
            ;;
        fedora)
            if ! dnf group list -v | grep -q "KDE Plasma Workspaces"; then
                install_pkg plasma-desktop
            else
                install_group "KDE Plasma Workspaces"
            fi
            ;;
        opensuse*|suse)
            if zypper -h | grep -q patterns; then
                install_pkg patterns-kde-kde
            else
                install_pkg plasma5-desktop
            fi
            ;;
        alpine)
            echo "Warning: Desktop environments in Alpine may require community/testing repos."
            install_pkg plasma-desktop || echo "Try enabling community/testing repositories."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    echo "KDE Plasma installed."
    post_install
}

install_xfce() {
    echo "Installing XFCE..."
    case $DISTRO in
        ubuntu|debian)
            install_pkg xfce4
            ;;
        arch)
            install_pkg xfce4 xfce4-goodies
            ;;
        fedora)
            if ! dnf group list -v | grep -q "Xfce Desktop"; then
                install_pkg xfce4-panel
            else
                install_group "Xfce Desktop"
            fi
            ;;
        opensuse*|suse)
            if zypper -h | grep -q patterns; then
                install_pkg patterns-xfce-xfce
            else
                install_pkg xfce4-panel
            fi
            ;;
        alpine)
            echo "Warning: Desktop environments in Alpine may require community/testing repos."
            install_pkg xfce4 xfce4-terminal || echo "Try enabling community/testing repositories."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    echo "XFCE installed."
    post_install
}

install_lxde() {
    echo "Installing LXDE..."
    case $DISTRO in
        ubuntu|debian)
            install_pkg lxde
            ;;
        arch)
            install_pkg lxde
            ;;
        fedora)
            if ! dnf group list -v | grep -q "LXDE Desktop"; then
                install_pkg lxde-common
            else
                install_group "LXDE Desktop"
            fi
            ;;
        opensuse*|suse)
            if zypper -h | grep -q patterns; then
                install_pkg patterns-lxde-lxde
            else
                install_pkg lxde-common
            fi
            ;;
        alpine)
            echo "Warning: Desktop environments in Alpine may require community/testing repos."
            install_pkg lxde-common || echo "Try enabling community/testing repositories."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    echo "LXDE installed."
    post_install
}

install_cinnamon() {
    echo "Installing Cinnamon..."
    case $DISTRO in
        ubuntu|debian)
            install_pkg cinnamon-desktop-environment
            ;;
        arch)
            install_pkg cinnamon
            ;;
        fedora)
            if ! dnf group list -v | grep -q "Cinnamon Desktop"; then
                install_pkg cinnamon
            else
                install_group "Cinnamon Desktop"
            fi
            ;;
        opensuse*|suse)
            if zypper -h | grep -q patterns; then
                install_pkg patterns-cinnamon-cinnamon
            else
                install_pkg cinnamon
            fi
            ;;
        alpine)
            echo "Warning: Cinnamon may not be available in Alpine's main repo."
            install_pkg cinnamon || echo "Try enabling community/testing repositories."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    echo "Cinnamon installed."
    post_install
}

install_mate() {
    echo "Installing MATE..."
    case $DISTRO in
        ubuntu|debian)
            install_pkg mate-desktop-environment
            ;;
        arch)
            install_pkg mate mate-extra
            ;;
        fedora)
            if ! dnf group list -v | grep -q "MATE Desktop"; then
                install_pkg mate-desktop
            else
                install_group "MATE Desktop"
            fi
            ;;
        opensuse*|suse)
            if zypper -h | grep -q patterns; then
                install_pkg patterns-mate-mate
            else
                install_pkg mate-desktop
            fi
            ;;
        alpine)
            echo "Warning: MATE may not be available in Alpine's main repo."
            install_pkg mate-desktop-environment || echo "Try enabling community/testing repositories."
            ;;
        *)
            echo "Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    echo "MATE installed."
    post_install
}

post_install() {
    echo "Installation complete. Reboot and select the new desktop environment from your login screen."
    if [[ $DISTRO == "alpine" ]]; then
        echo "If installation failed, try enabling community and testing repositories in /etc/apk/repositories."
    fi
}

detect_distro
check_root_or_sudo
check_pkg_manager

# Smarter apt-get update: run once at the start
if [[ $DISTRO =~ (ubuntu|debian) ]]; then
    run_cmd $SUDO_CMD apt-get update -q
fi

# Non-interactive CLI flags
case "$1" in
    --gnome) install_gnome; exit 0 ;;
    --kde) install_kde; exit 0 ;;
    --xfce) install_xfce; exit 0 ;;
    --lxde) install_lxde; exit 0 ;;
    --cinnamon) install_cinnamon; exit 0 ;;
    --mate) install_mate; exit 0 ;;
    --menu|"") # fall through to menu
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage."
        exit 1
        ;;
esac

while true; do
    echo "=============================="
    echo " Desktop Environment Installer"
    echo "=============================="
    echo "Detected distro: $DISTRO $VERSION_ID"
    echo "1) Install GNOME"
    echo "2) Install KDE Plasma"
    echo "3) Install XFCE"
    echo "4) Install LXDE"
    echo "5) Install Cinnamon"
    echo "6) Install MATE"
    echo "7) Exit"
    read -p "Choose an option [1-7]: " choice
    case $choice in
        1) install_gnome ;;
        2) install_kde ;;
        3) install_xfce ;;
        4) install_lxde ;;
        5) install_cinnamon ;;
        6) install_mate ;;
        7) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    echo ""
done