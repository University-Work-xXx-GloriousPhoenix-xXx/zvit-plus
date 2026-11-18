# Monitoring

Monitoring Stack:
- Prometheus
- Grafana
- cAdvisor

Monitoring Metrics:
- CPU usage
- Memory Usage
- Disk I/O
- Network traffic
- Container activity
- Container restarts

Configuration:
Prometheus config -> prometheus.yml
Monitoring services config -> docker-compose.yml

Start Monitoring:
From Monitoring directory -> "docker compose up -d"
Stop Monitoring:
From Monitoring directory -> "docker compose down"

Monitoring Access:
http://100.77.253.21:3000/
Main Page->Dashboards->Docker containers Overview
