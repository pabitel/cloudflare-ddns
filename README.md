# Cloudflare DDNS Updater
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg)](https://www.docker.com/)

自动更新 Cloudflare DNS A 记录的轻量级 DDNS 解决方案。支持 Docker 容器化部署和本地运行。

## 📚 功能特性

- 🔄 自动检测并更新公网 IP 地址
- 🔒 支持 Cloudflare API Token 认证
- 🐳 提供 Docker 支持，便于容器化部署
- ⏰ 支持自定义更新频率
- 🌐 多个 IP 检测服务源，确保可靠性
- 📝 详细的日志记录

## 🚀 快速开始

### 前置要求

- Cloudflare 账号和域名
- API Token（在 Cloudflare 仪表板中获取）
- 如果本地运行，需要安装：
  - curl
  - jq
  - bash

### Docker 部署（推荐）

1. 克隆仓库：
   ```bash
   git clone https://github.com/yourusername/ddns-bash.git
   cd ddns-bash
   ```

2. 复制环境变量模板并修改：
   ```bash
   cp .env.example .env
   ```

3. 构建并运行 Docker 容器：
   ```bash
   docker build -t ddns-bash .
   docker run -d --name ddns-bash --env-file .env ddns-bash
   ```

### 本地部署

1. 克隆仓库并进入目录：
   ```bash
   git clone https://github.com/yourusername/ddns-bash.git
   cd ddns-bash
   ```

2. 设置环境变量：
   ```bash
   cp .env.example .env
   # 编辑 .env 文件填入你的配置
   ```

3. 添加执行权限并运行：
   ```bash
   chmod +x ddns_update.sh
   ./ddns_update.sh
   ```

## ⚙️ 配置说明

在 `.env` 文件中配置以下环境变量：

| 变量名 | 描述 | 示例 |
|--------|------|------|
| CF_TOKEN | Cloudflare API Token | your_token_here |
| ZONE_ID | 域名的 Zone ID | your_zone_id |
| DOMAIN | 主域名 | example.com |
| SUBDOMAIN | 子域名 | ddns |
| CRON_SCHEDULE | Cron 更新周期 | */5 * * * * |

## 🔍 运行状态检查

查看日志：
```bash
# Docker 部署
docker logs ddns-bash

# 本地部署
cat /var/log/cron.log
```

## 🤝 贡献指南

欢迎提交 Pull Requests 和 Issues！

1. Fork 本仓库
2. 创建你的特性分支 (git checkout -b feature/AmazingFeature)
3. 提交你的修改 (git commit -m 'Add some AmazingFeature')
4. 推送到分支 (git push origin feature/AmazingFeature)
5. 创建一个 Pull Request

## 📜 开源许可

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 🔗 相关链接

- [Cloudflare API 文档](https://api.cloudflare.com/)
- [Docker 官方文档](https://docs.docker.com/)

## 🙏 致谢

- [ipify](https://www.ipify.org/) - IP 地址查询服务
- [其他IP查询服务提供商](https://github.com/yourusername/ddns-bash/blob/main/ddns_update.sh#L5)