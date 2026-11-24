#!/usr/bin/env bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run this installer with sudo'; exit 1; }
source_dir=$(cd -- "$(dirname -- "$0")" && pwd)
test -s /opt/zvit-plus/App/.env
docker compose version
install -d -o root -g root -m 755 /usr/local/share/zvitplus-cicd
install -d -o root -g root -m 700 /var/lib/zvitplus-cicd
install -o root -g root -m 755 "$source_dir/server-deploy.sh" /usr/local/sbin/zvitplus-deploy
cat > /usr/local/share/zvitplus-cicd/api.Dockerfile <<'EOF'
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY api/ /app/
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "ZvitPlus.API.dll"]
EOF
cat > /usr/local/share/zvitplus-cicd/web.Dockerfile <<'EOF'
FROM nginx:alpine
COPY web/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
EOF
sudoers=$(mktemp)
trap 'rm -f "$sudoers"' EXIT
printf 'developer2 ALL=(root) NOPASSWD: /usr/local/sbin/zvitplus-deploy "", /usr/local/sbin/zvitplus-deploy --rollback\n' > "$sudoers"
visudo -cf "$sudoers"
install -o root -g root -m 440 "$sudoers" /etc/sudoers.d/zvitplus-cicd
echo 'DEPLOY_HELPER_INSTALLED'
echo 'Jenkins and build tools have NOT been installed on this server'
