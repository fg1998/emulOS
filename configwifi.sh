#!/bin/bash

# =============================================
# Ultimate Wi-Fi Setup - RetroPie Style
# By ChatGPT & Fernando Garcia Inc.™ 😄
# =============================================

# Dependências necessárias
DEPENDENCIAS=("dialog" "iw" "nmtui")

# Função para verificar dependências
verificar_dependencias() {
    for prog in "${DEPENDENCIAS[@]}"; do
        if ! command -v "$prog" &> /dev/null; then
            dialog --yesno "O programa '$prog' não está instalado.\nDeseja instalar automaticamente?" 10 50
            if [ $? -eq 0 ]; then
                sudo apt update && sudo apt install -y "$prog"
            else
                dialog --msgbox "Dependência '$prog' ausente. Não é possível continuar." 8 50
                exit 1
            fi
        fi
    done
}

# Obtém a região atual
get_current_region() {
    iw reg get | grep country | awk '{print $2}' | cut -d':' -f1
}

# Menu de escolha de região
choose_region() {
    REGION=$(dialog --stdout --menu "Escolha sua região Wi-Fi" 20 50 15 \
        "BR" "Brasil" \
        "US" "Estados Unidos" \
        "EU" "Europa" \
        "JP" "Japão" \
        "CN" "China" \
        "RU" "Rússia" \
        "IN" "Índia" \
        "KR" "Coreia do Sul" \
        "ZA" "África do Sul" \
        "AU" "Austrália" \
        "GB" "Reino Unido" \
        "AR" "Argentina")

    if [ -n "$REGION" ]; then
        sudo iw reg set "$REGION"
        sleep 1
    else
        dialog --msgbox "Nenhuma região selecionada. Operação cancelada." 8 50
    fi
}

# Executa o nmtui
start_nmtui() {
    sudo nmtui
}

# Cabeçalho estilo RetroPie
show_header() {
    dialog --title "Wi-Fi Setup" --msgbox "Bem-vindo ao assistente de configuração Wi-Fi\nEstilo RetroPie-Setup" 8 50
}

# Menu principal
menu_principal() {
    while true; do
        CURRENT_REGION=$(get_current_region)
        if [ -z "$CURRENT_REGION" ] || [ "$CURRENT_REGION" == "00" ]; then
            REGION_STATUS="Não configurada"
        else
            REGION_STATUS="$CURRENT_REGION"
        fi

        OPCAO=$(dialog --stdout --menu "Região atual: $REGION_STATUS" 15 60 6 \
            1 "Configurar Região Wi-Fi" \
            2 "Configurar Wi-Fi (nmtui)" \
            3 "Sair")

        case $OPCAO in
            1) choose_region ;;
            2) start_nmtui ;;
            3) clear; exit 0 ;;
            *) break ;;
        esac
    done
}

# MAIN
clear
verificar_dependencias
show_header
menu_principal
