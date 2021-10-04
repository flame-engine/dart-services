#!/bin/bash -x

screen -S "flamepad server" -dm bash -c "grind serve-null-safety"
