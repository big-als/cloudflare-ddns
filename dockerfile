FROM mcr.microsoft.com/powershell

SHELL ["/bin/sh", "-c"]
RUN mkdir DDNS && apt update && apt install -y cron && apt install -y tzdata
ENV TZ=America/Los_Angeles CRON="0 0 * * *"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY ./cloudflare-ddns.ps1 /DDNS/cloudflare-ddns.ps1
COPY ./crontab /etc/cron.d/crontab
COPY ./ddns-kickoff.sh /DDNS/ddns-kickoff.sh
RUN chmod 0644 /etc/cron.d/crontab && chmod +x /DDNS/ddns-kickoff.sh && touch /var/log/cron.log
CMD  printenv > /etc/environment && sed -i "s/CRON_PLACEHOLDER/$CRON/g" /etc/cron.d/crontab && service cron restart && tail -f /var/log/cron.log
