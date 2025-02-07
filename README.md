# Cloudflare DDNS Updater
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg)](https://www.docker.com/)

A lightweight DDNS solution for automatically updating Cloudflare DNS A records. Supports both Docker containerized deployment and local running.

## 📚 Features

- 🔄 Automatic detection and update of public IP address
- 🔒 Cloudflare API Token authentication support
- 🐳 Docker support for easy containerized deployment
- ⏰ Customizable update frequency
- 🌐 Multiple IP detection services for reliability
- 📝 Detailed logging

## 🚀 Quick Start

### Prerequisites

- Cloudflare account and domain
- API Token (obtain from Cloudflare dashboard)
- For local running, you need:
  - curl
  - jq
  - bash

### Docker Deployment (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ddns-bash.git
   cd ddns-bash
   ```

2. Copy and modify environment variables:
   ```bash
   cp .env.example .env
   ```

3. Build and run Docker container:
   ```bash
   docker build -t ddns-bash .
   docker run -d --name ddns-bash --env-file .env ddns-bash
   ```

### Local Deployment

1. Clone the repository and enter directory:
   ```bash
   git clone https://github.com/yourusername/ddns-bash.git
   cd ddns-bash
   ```

2. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env file with your configuration
   ```

3. Add execution permission and run:
   ```bash
   chmod +x ddns_update.sh
   ./ddns_update.sh
   ```

## ⚙️ Configuration

Configure the following environment variables in `.env` file:

| Variable | Description | Example |
|----------|-------------|---------|
| CF_TOKEN | Cloudflare API Token | your_token_here |
| ZONE_ID | Domain Zone ID | your_zone_id |
| DOMAIN | Main domain | example.com |
| SUBDOMAIN | Subdomain | ddns |
| CRON_SCHEDULE | Cron update interval | */5 * * * * |

## 🔍 Status Check

View logs:
```bash
# Docker deployment
docker logs ddns-bash

# Local deployment
cat /var/log/cron.log
```

## 🤝 Contributing

Pull requests and issues are welcome!

1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Create a Pull Request

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 🔗 Related Links

- [Cloudflare API Documentation](https://api.cloudflare.com/)
- [Docker Documentation](https://docs.docker.com/)

## 🙏 Acknowledgments

- [ipify](https://www.ipify.org/) - IP address lookup service
- [Other IP lookup service providers](https://github.com/yourusername/ddns-bash/blob/main/ddns_update.sh#L5)