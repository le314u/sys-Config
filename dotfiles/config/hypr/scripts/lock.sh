#!/usr/bin/env bash

# Se o hyprlock já estiver rodando, não faz nada
if pgrep -x hyprlock > /dev/null; then
  exit 0
fi

# Caso contrário, trava a tela
hyprlock

