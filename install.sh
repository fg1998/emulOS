#!/usr/bin/env bash

# Verifica se o dialog está instalado
command -v dialog >/dev/null 2>&1 || { 
  echo "Instale o dialog: sudo apt-get install dialog" >&2
  exit 1
}

# Variáveis de layout
BACKTITLE="EmulOS install script"
TITLE=""
MENU="Escolha uma opção:"

HEIGHT=10
WIDTH=40
CHOICE_HEIGHT=4

# Definição das opções do menu
OPTIONS=(
  1 "Mostrar data e hora"
  2 "Pedir seu nome"
  3 "Sair"
)

# Exibe o menu e captura a escolha
CHOICE=$(dialog \
  --clear \
  --backtitle "$BACKTITLE" \
  --title "$TITLE" \
  --menu "$MENU" \
  $HEIGHT $WIDTH $CHOICE_HEIGHT \
  "${OPTIONS[@]}" \
  2>&1 >/dev/tty)

# Limpa a tela após sair do dialog
clear

case $CHOICE in
  1)
    # Caixa de texto simples
    dialog --title "Data e Hora" \
           --msgbox "$(date)" \
           7 50
    clear
    ;;
  2)
    # Caixa de entrada de texto
    NAME=$(dialog --clear \
                  --backtitle "$BACKTITLE" \
                  --title "Entrada de Texto" \
                  --inputbox "Qual é o seu nome?" \
                  8 40 \
                  2>&1 >/dev/tty)
    clear
    echo "Olá, $NAME!"
    ;;
  3)
    echo "Saindo..."
    ;;
  *)
    echo "Opção inválida."
    ;;
esac
