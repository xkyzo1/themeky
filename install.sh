#!/bin/bash
set -euo pipefail

# Warna
BIRU='\033[0;34m'
MERAH='\033[0;31m'
HIJAU='\033[0;32m'
KUNING='\033[0;33m'
NC='\033[0m'

# Token valid
valid_tokens=("kyzo12" "kyy11" "buy")

# Fungsi pause
pause() {
  echo ""
  read -rp "Tekan [Enter] untuk melanjutkan..."
}

# Banner awal
display_welcome() {
  clear
  cat <<EOF
${MERAH}[+] =============================================== [+]${NC}
${MERAH}[+]                AUTO INSTALLER THEME             [+]${NC}
${MERAH}[+]                  © KYZO OFFICIAL                [+]${NC}
${MERAH}[+] =============================================== [+]${NC}

Script ini dibuat untuk mempermudah penginstalan tema Pterodactyl.
Dilarang keras untuk diperjualbelikan. BY @kyzosan

Kontak:
  Telegram : @kyzosan
  YouTube  : @rvmzngaceng
  Credit   : Kyzo - Kyzo Official
EOF
  pause
}

# Otentikasi
authenticate() {
  local authenticated=false
  read -rp "Masukkan token: " USER_TOKEN
  for token in "${valid_tokens[@]}"; do
    if [[ "$USER_TOKEN" == "$token" ]]; then
      authenticated=true
      break
    fi
  done

  if [[ $authenticated == false ]]; then
    echo -e "${MERAH}Token tidak valid. Keluar.${NC}"
    exit 1
  fi
}

# Pilihan tema
select_theme() {
  clear
  echo -e "${MERAH}[+] =============================================== [+]${NC}"
  echo -e "${MERAH}[+]                   SELECT THEME                 [+]${NC}"
  echo -e "${MERAH}[+] =============================================== [+]${NC}"
  echo ""
  echo "1. Stellar"
  echo "2. Billing"
  echo "3. Enigma"
  echo "x. Kembali"
  echo ""
  read -rp "Masukkan pilihan (1/2/3/x): " SELECT_THEME

  case "$SELECT_THEME" in
    1) THEME_URL="https://github.com/DITZZ112/foxxhostt/raw/main/C2.zip" ;;
    2) THEME_URL="https://github.com/DITZZ112/foxxhostt/raw/main/C1.zip" ;;
    3) THEME_URL="https://github.com/DITZZ112/foxxhostt/raw/main/C3.zip" ;;
    x) return 1 ;;
    *) echo -e "${MERAH}Pilihan tidak valid.${NC}" ; sleep 2 ; return 1 ;;
  esac
  return 0
}

# Install theme
install_theme() {
  while ! select_theme; do :; done

  rm -rf /root/pterodactyl || true
  wget -q "$THEME_URL"
  unzip -o "$(basename "$THEME_URL")" -d /root/

  case "$SELECT_THEME" in
    1)
      echo -e "${BIRU}Menginstall Stellar...${NC}"
      ;;
    2)
      echo -e "${BIRU}Menginstall Billing...${NC}"
      ;;
    3)
      echo -e "${BIRU}Menginstall Enigma...${NC}"
      read -rp "Masukkan link untuk 'LINK_BC_BOT': " LINK_WA
      read -rp "Masukkan nama untuk 'NAMA_OWNER_PANEL': " LINK_GROUP
      read -rp "Masukkan link untuk 'LINK_GC_INFO': " LINK_CHNL

      sed -i "s|LINK_WA|$LINK_WA|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      sed -i "s|LINK_GROUP|$LINK_GROUP|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      sed -i "s|LINK_CHNL|$LINK_CHNL|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
      ;;
  esac

  cp -rfT /root/pterodactyl /var/www/pterodactyl
  curl -sL https://deb.nodesource.com/setup_16.x | bash -
  apt install -y nodejs
  npm i -g yarn
  cd /var/www/pterodactyl
  yarn add react-feather
  php artisan migrate
  [[ "$SELECT_THEME" == "2" ]] && php artisan billing:install stable
  yarn build:production
  php artisan view:clear

  rm -f /root/C{1,2,3}.zip
  rm -rf /root/pterodactyl

  echo -e "${HIJAU}Installasi tema selesai.${NC}"
  pause
}

# Uninstall theme
uninstall_theme() {
  echo -e "${MERAH}Menghapus tema...${NC}"
  bash <(curl -s https://raw.githubusercontent.com/xkyzo1/themeky/refs/heads/main/repair.sh)
  echo -e "${HIJAU}Tema berhasil dihapus.${NC}"
  pause
}

# Main menu
main_menu() {
  while true; do
    clear
    echo -e "${MERAH}[+] =============================================== [+]${NC}"
    echo -e "${MERAH}[+]                   MAIN MENU                     [+]${NC}"
    echo -e "${MERAH}[+] =============================================== [+]${NC}"
    echo ""
    echo "1. Install Theme"
    echo "2. Uninstall Theme"
    echo "x. Exit"
    echo ""
    read -rp "Masukkan pilihan (1/2/x): " MENU_CHOICE

    case "$MENU_CHOICE" in
      1) install_theme ;;
      2) uninstall_theme ;;
      x) echo "Keluar dari script." ; exit 0 ;;
      *) echo "Pilihan tidak valid." ; sleep 2 ;;
    esac
  done
}

# Run
display_welcome
authenticate
main_menu
