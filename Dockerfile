FROM centos:centos7

MAINTAINER Roberto Cangiamila <roberto.cangiamila@par-tec.it>

EXPOSE 9000

ARG SONARQUBE_VERSION

ENV APP_HOME=/opt/sonarqube
ENV HOME=${APP_HOME}

ENV SONARQUBE_DOWNLOAD_URL=https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip
ENV SONARQUBE_ASC_DOWNLOAD_URL=https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip.asc

LABEL name="SonarQube" \
      io.k8s.display-name="SonarQube" \
      io.k8s.description="Provide a SonarQube image to run on Red Hat OpenShift" \
      io.openshift.expose-services="9000" \
      io.openshift.tags="sonarqube" \
      version=${SONARQUBE_VERSION}

RUN yum install -y epel-release

RUN INSTALL_PACKAGES="unzip wget vim-enhanced tzdata nano gettext nss_wrapper curl sed which less java-1.8.0-openjdk" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PACKAGES && \
    rpm -V $INSTALL_PACKAGES && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    wget --no-verbose -L -O sonarqube.zip ${SONARQUBE_DOWNLOAD_URL} && \
    unzip sonarqube.zip -d /opt && \
    mv /opt/sonarqube-${SONARQUBE_VERSION} /opt/sonarqube && \
    rm -f sonarqube.zip* && \
    rm -rf $APP_HOME/bin/*

COPY bin/ ${APP_HOME}/bin

RUN useradd -m -u 1001 -g 0 -m -s /sbin/nologin -d ${HOME} sonar && \
    cat /etc/passwd > /etc/passwd.template && \
    chmod -R a+rwx ${APP_HOME} && \
    chown -R sonar:0 ${APP_HOME} && \
    chmod -R g=u /etc/passwd

ENV PATH=$PATH:${APP_HOME}/bin

USER 1001

WORKDIR ${APP_HOME}

VOLUME ${APP_HOME}/data

ENTRYPOINT [ "run_sonarqube" ]
