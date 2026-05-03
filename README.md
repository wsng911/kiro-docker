# kiro-cli Docker

基于 Debian 12 的 kiro-cli 多架构镜像，支持 `linux/amd64` 和 `linux/arm64`。

Docker Hub: [wsng911/kiro-cli](https://hub.docker.com/r/wsng911/kiro-cli)

## 部署

### 1. 创建目录和配置

```bash
mkdir -p /home/kiro/.kiro/settings

cat > /home/kiro/.kiro/settings/cli.json << 'EOF'
{
  "chat.defaultModel": "claude-sonnet-4",
  "chat.defaultAgent": "kiro_default",
  "chat.enableNotifications": false,
  "chat.greeting.enabled": false,
  "telemetry.enabled": false,
  "knowledge.indexType": "fast"
}
EOF

cat > /home/kiro/.env << 'EOF'
GITHUB_TOKEN=your_github_token
DOCKER_HUB_TOKEN=your_dockerhub_token
DOCKER_HUB_USERNAME=your_username
EOF

chown -R 1000:1000 /home/kiro/.kiro
```

### 2. 首次登录（只需一次）

```bash
docker run -it --rm \
  -v /home/kiro/.kiro:/home/kiro/.kiro \
  -v kiro_data:/home/kiro/.local/share/kiro-cli \
  --env-file /home/kiro/.env \
  wsng911/kiro-cli:latest kiro-cli login --use-device-flow
```

### 3. 设置别名

```bash
echo "alias kiro='docker run -it --rm -v /home/kiro/.kiro:/home/kiro/.kiro -v kiro_data:/home/kiro/.local/share/kiro-cli --env-file /home/kiro/.env wsng911/kiro-cli:latest bash'" >> ~/.bashrc
source ~/.bashrc
```

### 4. 使用

```bash
kiro              # 进入容器
kiro-cli chat     # 启动对话
kiro-cli whoami   # 查看登录状态
```

## 说明

- 凭证持久化在 Docker named volume `kiro_data`，重启容器无需重新登录
- 配置文件持久化在宿主机 `/home/kiro/.kiro/settings/`
- `.env` 中的 token 通过环境变量注入容器，不写入镜像
