FROM openjdk:8-jdk-alpine

LABEL "com.github.actions.name"="sbt"
LABEL "com.github.actions.description"="Executes sbt build commands"
LABEL "com.github.actions.icon"="box"
LABEL "com.github.actions.color"="blue"

ENV sbt_version 0.13.18
ENV sbt_home /usr/local/sbt
ENV PATH ${PATH}:${sbt_home}/bin

# Even though the docs say that HOME points to /github/home, SBT looks in /root for its config
# COPY artifactory-realm-credentials.sbt /root/.sbt/1.0/

RUN apk --no-cache --update add bash wget git && \
    mkdir -p "$sbt_home" && \
    wget -qO - --no-check-certificate "https://github.com/sbt/sbt/releases/download/v$sbt_version/sbt-$sbt_version.tgz" | tar xz -C $sbt_home --strip-components=1 && \
    apk del wget && \
    sbt sbtVersion

RUN apk -v --update add \
    python \
    py-pip \
    groff \
    less \
    mailcap \
    && \
    pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
