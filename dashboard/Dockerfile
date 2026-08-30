FROM balenablocks/dashboard:raspberrypi4-64

# Grafana config
COPY ./custom.ini /usr/share/grafana/conf/

# Grafana dash config
COPY ./dashboard.json /usr/share/grafana/conf/provisioning/dashboards
COPY ./dashboards.yml /usr/share/grafana/conf/provisioning/dashboards
