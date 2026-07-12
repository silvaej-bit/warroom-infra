#!/bin/bash
# Cloud-init: executado uma unica vez na primeira inicializacao da VM
set -euo pipefail

# --- Docker ---
apt-get update -y
apt-get install -y ca-certificates curl gnupg

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker

# --- Diretorio da aplicacao ---
mkdir -p /opt/warroom
chmod 700 /opt/warroom

# --- Credenciais (nao ficam no docker-compose.yml) ---
cat > /opt/warroom/.env << 'ENVEOF'
POSTGRES_USER=${db_user}
POSTGRES_PASSWORD=${db_password}
WARROOM_DB_USER=${db_user}
WARROOM_DB_PASSWORD=${db_password}
ENVEOF
chmod 600 /opt/warroom/.env

# --- docker-compose.yml ---
cat > /opt/warroom/docker-compose.yml << 'COMPOSEEOF'
services:
  db:
    image: postgres:16-alpine
    restart: unless-stopped
    env_file: .env
    environment:
      POSTGRES_DB: warroom
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    image: ${image_name}
    restart: unless-stopped
    ports:
      - "8080:8080"
    env_file: .env
    environment:
      SPRING_PROFILES_ACTIVE: dev
      WARROOM_DB_URL: jdbc:postgresql://db:5432/warroom
    depends_on:
      db:
        condition: service_healthy

volumes:
  pgdata:
COMPOSEEOF

# --- Subir containers (best-effort: imagem pode nao existir no primeiro boot) ---
cd /opt/warroom
docker compose pull || true
docker compose up -d || true

# --- Servico systemd para reiniciar no boot ---
cat > /etc/systemd/system/warroom.service << 'SVCEOF'
[Unit]
Description=War Room Service (Docker Compose)
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/warroom
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl enable warroom
