FROM alpine:3.22.2
MAINTAINER Uri Savelchev <alterrebe@gmail.com>

# Packages: update
RUN apk -U add \
    postfix \
    ca-certificates \
    libsasl \
    cyrus-sasl \
    cyrus-sasl-login \
    lmdb \
    py3-pip \
    py3-setuptools \
    py3-wheel \
    supervisor \
    rsyslog

RUN pip install --break-system-packages jinja2-cli[yaml]

# Add files
ADD conf /root/conf
RUN mkfifo /var/spool/postfix/public/pickup \
    && ln -s /etc/postfix/aliases /etc/aliases \
    && touch /etc/postfix/sender_canonical \
    && touch /etc/postfix/recipient_canonical \
    && touch /etc/postfix/transport_maps

# Configure: supervisor
ADD bin/dfg.sh /usr/local/bin/
ADD conf/supervisor-all.ini /etc/supervisor.d/
ADD conf/supervisord.conf /etc/supervisord.conf

# Runner
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh

# Declare
EXPOSE 25

CMD ["/root/run.sh"]
