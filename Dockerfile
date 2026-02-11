FROM opensuse/tumbleweed:latest AS install

RUN zypper update --no-confirm && \
    zypper install --no-confirm ca-certificates

ARG AGENTGATEWAY_VERSION
RUN curl -L https://github.com/agentgateway/agentgateway/releases/download/v${AGENTGATEWAY_VERSION}/agentgateway-linux-amd64 -o /usr/bin/agentgateway

FROM opensuse/tumbleweed:latest AS base

RUN zypper update --no-confirm && \
    rpm -e --allmatches $(rpm -qa --qf "%{NAME}\n" | grep -v -E "bash|coreutils|filesystem|glibc$|libacl1|libattr1|libcap2|libgcc_s1|libgmp|libncurses|libpcre|libreadline|libselinux|libstdc\+\+|openSUSE-release|system-user-root|terminfo-base") && \
    rm -Rf /etc/zypp && \
    rm -Rf /usr/lib/zypp* && \
    rm -Rf /var/{cache,log,run}/* && \
    rm -Rf /var/lib/zypp && \
    rm -Rf /usr/lib/rpm && \
    rm -Rf /usr/lib/sysimage/rpm && \
    rm -Rf /usr/share/man && \
    rm -Rf /usr/local && \
    rm -Rf /srv/www && \
    rm -Rf /tmp/*

COPY --from=install --chmod=755 /usr/bin/agentgateway /usr/bin/agentgateway
COPY --from=install --chmod=444 /var/lib/ca-certificates/ca-bundle.pem /etc/ssl/ca-bundle.pem

WORKDIR /app
ADD config.yaml /app/config.yaml

ENV SSL_CERT_FILE=/etc/ssl/ca-bundle.pem

EXPOSE 3000 15000

CMD ["/usr/bin/agentgateway", "-f", "/app/config.yaml"]
