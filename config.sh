#!/bin/sh

# Exibe uma mensagem para facilitar o rastreamento
log() {
    echo ">>> $1"
}

log "Iniciando a configuração do sistema para usar SDDM, Xorg e i3wm..."

# Atualizar repositórios e sistema
log "Atualizando repositórios e sistema..."
apk update && apk upgrade --available

# Instalar pacotes básicos e utilitários
log "Instalando pacotes básicos..."
apk add vim curl bash lsb-release

# Instalar Xorg e drivers gráficos
log "Instalando Xorg e drivers gráficos..."
apk add xorg-server xf86-input-libinput mesa-dri-gallium

# Detectar e instalar drivers de GPU
log "Detectando GPU e instalando drivers correspondentes..."
GPU=$(lspci | grep -i 'vga' | awk '{print tolower($0)}')

if echo "$GPU" | grep -q "intel"; then
    apk add xf86-video-intel
    log "Driver Intel instalado."
elif echo "$GPU" | grep -q "nvidia"; then
    apk add xf86-video-nouveau
    log "Driver Nouveau para NVIDIA instalado."
elif echo "$GPU" | grep -q "amd"; then
    apk add xf86-video-amdgpu
    log "Driver AMD instalado."
else
    log "GPU não identificada ou driver genérico será usado."
fi

# Instalar SDDM (Display Manager)
log "Instalando e configurando SDDM..."
apk add sddm
rc-update add sddm
rc-service sddm start

# Instalar i3wm e utilitários relacionados
log "Instalando i3wm e ferramentas associadas..."
apk add i3wm i3status i3lock dmenu alacritty ttf-dejavu ttf-freefont font-noto

# Configurar D-Bus
log "Configurando D-Bus..."
apk add dbus
rc-update add dbus
rc-service dbus start

# Criar um arquivo de configuração padrão para o SDDM
log "Configurando sessão padrão para SDDM..."
mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/default.conf
[Autologin]
User=pedro
Session=i3
EOF

# Configurar um usuário para o sistema
log "Configurando usuário..."
DEFAULT_USER="pedro"
if ! id -u "$DEFAULT_USER" >/dev/null 2>&1; then
    log "Criando o usuário $DEFAULT_USER..."
    adduser -D "$DEFAULT_USER"
    echo "Troque 'seu_usuario' pelo seu nome de usuário no arquivo /etc/sddm.conf.d/default.conf."
else
    log "Usuário '$DEFAULT_USER' já existe."
fi

# Configuração adicional para o i3wm
log "Criando configurações padrão para i3wm..."
mkdir -p /home/"$DEFAULT_USER"/.config/i3
cat <<EOF > /home/"$DEFAULT_USER"/.config/i3/config
# Configuração básica do i3wm
set \$mod Mod4
bindsym \$mod+Return exec alacritty
bindsym \$mod+d exec dmenu_run
bindsym \$mod+Shift+q kill
EOF

chown -R "$DEFAULT_USER":"$DEFAULT_USER" /home/"$DEFAULT_USER"/.config

# Reiniciar o sistema
log "Configuração concluída! Reinicie o sistema para aplicar as alterações."
log "Use o comando: reboot"
