
REPO_FILE="/etc/apk/repositories"

# Verifique se o arquivo existe
if [ ! -f "$REPO_FILE" ]; then
  echo "Arquivo de repositórios não encontrado: $REPO_FILE"
  exit 1
fi


sed -i '/^#.*community/s/^#//' "$REPO_FILE"

grep 'community' "$REPO_FILE" && echo "Repositório 'community' descomentado com sucesso!" || echo "Erro ao descomentar o repositório 'community'."

# Atualize a lista de pacotes
apk update && apk upgrade 

setup-xorg-base
apk add plasma kde-applications sddm dbus plasma desktop konsole dolphin thunar   
apk add pulseaudio pulseaudio-utils alsa-utils xf86-video-intel pulseaudio-alsa
apk add firefox neovim sudo 
adduser pedro wheel 
visudo 
rc-update add dbus 
rc-update add sddm
