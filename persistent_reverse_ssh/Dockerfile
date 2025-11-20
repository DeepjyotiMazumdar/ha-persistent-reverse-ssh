FROM alpine:3.18

RUN apk add --no-cache openssh-client autossh bash ca-certificates jq \
    && mkdir -p /data

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["bash", "/run.sh"]
