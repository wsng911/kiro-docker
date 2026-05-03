FROM debian:12-slim

RUN apt-get update && apt-get install -y \
    curl unzip git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/kiro-cli -s /bin/bash kiro-cli

USER kiro-cli
WORKDIR /home/kiro-cli

RUN curl --proto '=https' --tlsv1.2 -sSf \
    'https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip' \
    -o /tmp/kirocli.zip && \
    unzip /tmp/kirocli.zip -d /tmp && \
    /tmp/kirocli/install.sh --no-confirm && \
    rm -rf /tmp/kirocli*

ENV PATH="/home/kiro-cli/.local/bin:$PATH"

COPY --chown=kiro-cli:kiro-cli config/ /home/kiro-cli/.kiro/

CMD ["bash"]
