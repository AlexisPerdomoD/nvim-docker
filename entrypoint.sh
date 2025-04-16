#!/bin/bash

# Asegurarse de que los directorios de Neovim existen
mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim
mkdir -p ~/.local/state/nvim
mkdir -p ~/.cache/nvim

# Iniciar en un shell interactivo
if [ -z "$1" ]; then
    # Si no hay argumentos, abrir nvim
    exec nvim
else
    # Si hay argumentos, ejecutarlos
    exec "$@"
fi
