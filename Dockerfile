FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias básicas
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    gnupg \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    ripgrep \
    fd-find \
    unzip \
    tzdata \
    locales \
    ninja-build \
    gettext \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Instalar Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs

# Instalar herramientas de desarrollo para TypeScript/JavaScript
RUN npm install -g typescript ts-node eslint prettier

# Instalar Go
RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz \
    && rm go1.21.0.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# Instalar herramientas de Go
RUN go install golang.org/x/tools/gopls@latest \
    && go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest

# Instalar .NET SDK para C#
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-7.0

# Instalar Neovim desde el código fuente para tener la última versión
RUN git clone https://github.com/neovim/neovim.git /tmp/neovim \
    && cd /tmp/neovim \
    && git checkout stable \
    && make CMAKE_BUILD_TYPE=RelWithDebInfo \
    && make install \
    && rm -rf /tmp/neovim

# Crear usuario no root
RUN useradd -m -s /bin/bash developer
USER developer
WORKDIR /home/developer
ENV PATH="/home/developer/.local/bin:${PATH}"
ENV NPM_CONFIG_PREFIX=/home/developer/.npm-global
ENV PATH=$PATH:/home/developer/.npm-global/bin

# Configurar directorios para Neovim
RUN mkdir -p /home/developer/.config/nvim \
    && mkdir -p /home/developer/.local/share/nvim \
    && mkdir -p /home/developer/.local/state/nvim \
    && mkdir -p /home/developer/.cache/nvim

# Instalar herramientas de LSP y formateadores para JavaScript/TypeScript/Web
RUN npm install -g \
    @tailwindcss/language-server \
    typescript-language-server \
    vscode-langservers-extracted \
    cssmodules-language-server \
    bash-language-server \
    eslint_d \
    prettier \
    js-beautify \
    emmet-ls \
    stylelint

# Instalar herramientas adicionales para formateo y linting
RUN pip3 install --user pynvim black isort flake8 pylint

# Crear directorio de trabajo
RUN mkdir -p /home/developer/workspace

# Script de entrada
COPY --chown=developer:developer entrypoint.sh /home/developer/entrypoint.sh
RUN chmod +x /home/developer/entrypoint.sh

# Punto de montaje para la configuración de Neovim
VOLUME ["/home/developer/.config/nvim"]
# Punto de montaje para plugins y datos persistentes
VOLUME ["/home/developer/.local/share/nvim"]
# Punto de montaje para el directorio de trabajo
VOLUME ["/home/developer/workspace"]

WORKDIR /home/developer/workspace
ENTRYPOINT ["/home/developer/entrypoint.sh"]
