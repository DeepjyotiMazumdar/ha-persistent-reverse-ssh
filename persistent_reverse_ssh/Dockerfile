ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache openssh-client autossh ca-certificates jq \
    && mkdir -p /data

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]



