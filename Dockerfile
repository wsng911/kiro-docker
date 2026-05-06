FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    curl unzip git ca-certificates \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
       > /etc/apt/sources.list.d/docker.list \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /etc/apt/keyrings/githubcli.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y docker-ce-cli docker-buildx-plugin gh \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/kiro -s /bin/bash -u 1000 kiro \
    && usermod -aG tty kiro

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER kiro
WORKDIR /home/kiro
RUN mkdir -p /home/kiro/.local/bin /home/kiro/.local/run /home/kiro/.kiro/settings

# 安装 kiro-cli 2.2.0（2.2.1 存在容器内 TUI 渲染 bug）
ARG KIRO_VERSION=2.2.0
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH_NAME="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then ARCH_NAME="aarch64"; \
    else echo "Unsupported arch: $ARCH" && exit 1; fi && \
    curl --proto '=https' --tlsv1.2 -sSf \
      "https://desktop-release.q.us-east-1.amazonaws.com/${KIRO_VERSION}/kirocli-${ARCH_NAME}-linux.zip" \
      -o /tmp/kirocli.zip && \
    unzip /tmp/kirocli.zip -d /tmp && \
    /tmp/kirocli/install.sh --no-confirm && \
    rm -rf /tmp/kirocli*

# 安装 github-mcp-server
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH_NAME="x86_64"; \
    elif [ "$ARCH" = "aarch64" ]; then ARCH_NAME="arm64"; \
    else echo "Unsupported arch: $ARCH" && exit 1; fi && \
    curl -fsSL \
      "https://github.com/github/github-mcp-server/releases/latest/download/github-mcp-server_Linux_${ARCH_NAME}.tar.gz" \
      | tar -xz -C /home/kiro/.local/bin github-mcp-server

COPY --chown=kiro:kiro config/settings/ /home/kiro/.kiro/settings/

ENV PATH="/home/kiro/.local/bin:$PATH"
ENV XDG_RUNTIME_DIR="/home/kiro/.local/run"
ENV SHELL="/bin/bash"

USER root
ENTRYPOINT ["/entrypoint.sh"]
CMD ["su", "-", "kiro", "-c", "bash"]
