FROM balenalib/raspberrypi4-64:buster

RUN apt-get update \
 && apt-get install -yq cron tzdata gettext-base moreutils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

COPY restart-cron /etc/cron.d/restart-cron
RUN chmod 0644 /etc/cron.d/restart-cron
RUN crontab /etc/cron.d/restart-cron
RUN touch /var/log/cron.log

WORKDIR /app

COPY start.sh start.sh
RUN chmod +x start.sh

COPY wifi-check.sh wifi-check.sh
RUN chmod +x wifi-check.sh

ENV TZ=Europe/Stockholm

CMD ["./start.sh"]
