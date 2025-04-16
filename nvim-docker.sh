#!/bin/zsh
# Guardar como nvim-docker.sh

# Obtener el directorio actual
CURRENT_DIR=$(pwd)

# Obtener el directorio donde está instalada la configuración de Docker para Neovim
NVIM_DOCKER_HOME=${NVIM_DOCKER_HOME:-"$HOME/nvim-docker"}

# Verificar si estamos dentro del directorio $NVIM_DOCKER_HOME
if [[ "$CURRENT_DIR" == "$NVIM_DOCKER_HOME"* ]]; then
    # Estamos dentro del directorio nvim-docker, usar rutas relativas
    WORKSPACE_PATH="./workspace"
else
    # Estamos fuera del directorio nvim-docker, montar el directorio actual como workspace
    WORKSPACE_PATH="$CURRENT_DIR:/home/developer/workspace"
fi

# Si ya existe un contenedor en ejecución, adjuntarse a él
if docker ps -q -f name=neovim-dev | grep -q .; then
    # El contenedor ya está en ejecución, adjuntarse a él
    docker exec -it neovim-dev nvim "$@"
else
    # Iniciar un nuevo contenedor
    docker run -it --rm \
        --name neovim-dev \
        -e TERM=xterm-256color \
        -v "$WORKSPACE_PATH" \
        -v "$NVIM_DOCKER_HOME/config/nvim:/home/developer/.config/nvim" \
        -v nvim-plugins:/home/developer/.local/share/nvim \
        -v nvim-state:/home/developer/.local/state/nvim \
        -v nvim-cache:/home/developer/.cache/nvim \
        neovim-dev "$@"
fi
