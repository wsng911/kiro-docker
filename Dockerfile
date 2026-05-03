FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    curl unzip git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/kiro -s /bin/bash kiro

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
