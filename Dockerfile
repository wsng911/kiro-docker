FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    curl unzip git ca-certificates \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce-cli docker-buildx-plugin \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/kiro -s /bin/bash kiro \
    && groupadd -f docker \
    && usermod -aG docker kiro

USER kiro
WORKDIR /home/kiro

RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
      URL="https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip"; \
    elif [ "$ARCH" = "aarch64" ]; then \
      URL="https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-aarch64-linux.zip"; \
    else \
      echo "Unsupported arch: $ARCH" && exit 1; \
    fi && \
    curl --proto '=https' --tlsv1.2 -sSf "$URL" -o /tmp/kirocli.zip && \
    unzip /tmp/kirocli.zip -d /tmp && \
    /tmp/kirocli/install.sh --no-confirm && \
    rm -rf /tmp/kirocli*

ENV PATH="/home/kiro/.local/bin:$PATH"
CMD ["bash"]
