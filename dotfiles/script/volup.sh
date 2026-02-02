#!/bin/bash
MAXVOL=100
CURVOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)

if [ "$CURVOL" -lt "$MAXVOL" ]; then
  pactl set-sink-volume @DEFAULT_SINK@ +5%
fi
