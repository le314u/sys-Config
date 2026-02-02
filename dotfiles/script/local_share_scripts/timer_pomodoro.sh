#!/bin/bash

# Pomodoro Avançado com hyperlock e mpv
# Autor: Lucas Mateus

# ----------------------------
# Função help
# ----------------------------
if [[ "$1" == "--help" ]]; then
    echo "Pomodoro Avançado"
    echo
    echo "Uso:"
    echo "  ./pomodoro.sh          -> Inicia Pomodoro padrão"
    echo "  ./pomodoro.sh --help   -> Exibe esta ajuda"
    echo
    echo "Funcionalidades:"
    echo "  - Timer de Pomodoro (25min foco / 5min pausa / 15min pausa longa)"
    echo "  - Notificações progressivas a cada 5min, 1min, e nos últimos 60s detalhadas"
    echo "  - Toca música ao final do Pomodoro sem abrir terminal"
    echo "  - Bloqueia a tela automaticamente com hyperlock"
    exit 0
fi

# ----------------------------
# Configurações
# ----------------------------
TRABALHO=25        # minutos de foco
PAUSA_CURTA=5      # minutos de intervalo curto
PAUSA_LONGA=15     # minutos de intervalo longo
CICLOS=4           # pomodoros antes do intervalo longo
MUSICA="$HOME/Documentos/Music/The Phantom of the Opera.mp3"
VOLUME=50          # volume da música (0-100)

# ----------------------------
# Função de contagem regressiva com notificações progressivas
# ----------------------------
contagem_notify() {
    TOTAL=$(( $1 * 60 ))

    while [ $TOTAL -gt 0 ]; do
        MIN=$((TOTAL / 60))
        SEC=$((TOTAL % 60))
        printf "\r%02d:%02d" $MIN $SEC

        # Último minuto: notificações detalhadas
        if [ $TOTAL -le 60 ]; then
            case $TOTAL in
                30|15|5|4|3|2|1)
                    notify-send "Pomodoro" "Último minuto: $MIN min $SEC seg restantes"
                    ;;
            esac
        # Últimos 5 minutos: notificação a cada minuto
        elif [ $TOTAL -le 300 ]; then
            if [ $SEC -eq 0 ]; then
                notify-send "Pomodoro" "Tempo restante: $MIN min"
            fi
        # Acima de 5 minutos: notificação a cada 5 minutos
        elif (( TOTAL % 300 == 0 )); then
            notify-send "Pomodoro" "Tempo restante: $MIN min"
        fi

        sleep 1
        TOTAL=$((TOTAL - 1))
    done
    echo
}

# ----------------------------
# Função de alarme
# ----------------------------
alarme() {
    # Toca a música no mpv sem terminal e sem vídeo
    if [[ -f "$MUSICA" ]]; then
        mpv --no-terminal --no-video --volume=$VOLUME "$MUSICA" &
    fi

    # Bloqueia a tela com hyprlock
    if command -v hyprlock >/dev/null 2>&1; then
        hyprlock
    else
        echo "hyperlock não encontrado, não foi possível bloquear a tela."
    fi
}

# ----------------------------
# Loop principal
# ----------------------------
for (( i=1; i<=CICLOS; i++ ))
do
    echo "Pomodoro $i/$CICLOS - Foque agora!"
    notify-send "Pomodoro" "Pomodoro $i: Comece a focar! ⏰"
    contagem_notify $TRABALHO
    alarme

    if [ $i -lt $CICLOS ]; then
        echo "Intervalo curto! 🛋️"
        notify-send "Pomodoro" "Intervalo curto: Descanse $PAUSA_CURTA minutos"
        contagem_notify $PAUSA_CURTA
        alarme
    else
        echo "Intervalo longo! 🌴"
        notify-send "Pomodoro" "Intervalo longo: Descanse $PAUSA_LONGA minutos"
        contagem_notify $PAUSA_LONGA
        alarme
    fi
done

echo "Todos os pomodoros concluídos! 🎉"
notify-send "Pomodoro" "Todos os pomodoros concluídos! 🎉"
