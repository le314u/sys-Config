#!/bin/bash

# workspace atual
CURRENT=$(hyprctl activeworkspace -j | jq -r '.id')

# lista de workspaces com janelas, ordenados
WS_LIST=($(hyprctl workspaces -j | jq 'sort_by(.id) | map(select(.windows > 0)) | .[].id'))

# se não houver nenhum workspace ativo, sai
[ ${#WS_LIST[@]} -eq 0 ] && exit 0

# procura posição do workspace atual na lista
NEXT=""
for i in "${!WS_LIST[@]}"; do
    if [ "${WS_LIST[$i]}" -eq "$CURRENT" ]; then
        NEXT_INDEX=$(( (i + 1) % ${#WS_LIST[@]} ))
        NEXT=${WS_LIST[$NEXT_INDEX]}
        break
    fi
done

# se não encontrou (por exemplo, workspace atual vazio), vai para o primeiro da lista
[ -z "$NEXT" ] && NEXT=${WS_LIST[0]}

# troca para o próximo
hyprctl dispatch workspace "$NEXT"
