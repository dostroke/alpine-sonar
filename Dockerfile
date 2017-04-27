# ALPINE LINUX BASED SONARQUBE
FROM alpine:3.5
MAINTAINER Github:dostroke <isgenez@gmail.com>

######################
### BASIC SETTINGS ###
######################
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    SONAR_VER=6.3.1 \
    SONARQUBE_HOME=/opt/sonarqube \
    SONAR_JDBC_USR=sonar \
    SONAR_JDBC_PWD=sonar \
    SONAR_JDBC_URL=jdbc://mysql:3306/sonar

RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates unzip && \
    apk add --no-cache gnupg libressl

#############################
### INSTALL GLIBC 2.25-r0 ###
#############################
RUN wget https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub \
    -O /etc/apk/keys/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk \
         https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk \
         https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk && \
    apk add --no-cache glibc-2.25-r0.apk glibc-bin-2.25-r0.apk glibc-i18n-2.25-r0.apk && \
    rm /etc/apk/keys/sgerrand.rsa.pub && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    apk del glibc-i18n && \
    rm /root/.wget-hsts && \
    rm glibc-2.25-r0.apk glibc-bin-2.25-r0.apk glibc-i18n-2.25-r0.apk

########################
### TIMEZONE SETTING ###
########################
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    echo "Asia/Seoul" > /etc/timezone && \
    date && apk del tzdata

################################
### INSTALL ORACLE JDK 8u131 ###
################################
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
    "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz" -O /tmp/jdk-${JDK_VER}-linux-x64.tar.gz && \
    tar -xvf /tmp/jdk-${JDK_VER}-linux-x64.tar.gz -C /tmp/ && \
    mkdir -p /usr/lib/jvm && mv /tmp/jdk1.8.0_131 ${JAVA_HOME} && \
    rm -rf "${JAVA_HOME}/"src.zip && \
    rm -rf "${JAVA_HOME}/lib/missioncontrol" \
           "${JAVA_HOME}/lib/visualvm" \
           "${JAVA_HOME}/lib/"*javafx* \
           "${JAVA_HOME}/jre/lib/plugin.jar" \
           "${JAVA_HOME}/jre/lib/ext/jfxrt.jar" \
           "${JAVA_HOME}/jre/bin/javaws" \
           "${JAVA_HOME}/jre/lib/javaws.jar" \
           "${JAVA_HOME}/jre/lib/desktop" \
           "${JAVA_HOME}/jre/plugin" \
           "${JAVA_HOME}/jre/lib/"deploy* \
           "${JAVA_HOME}/jre/lib/"*javafx* \
           "${JAVA_HOME}/jre/lib/"*jfx* \
           "${JAVA_HOME}/jre/lib/amd64/libdecora_sse.so" \
           "${JAVA_HOME}/jre/lib/amd64/"libprism_*.so \
           "${JAVA_HOME}/jre/lib/amd64/libfxplugins.so" \
           "${JAVA_HOME}/jre/lib/amd64/libglass.so" \
           "${JAVA_HOME}/jre/lib/amd64/libgstreamer-lite.so" \
           "${JAVA_HOME}/jre/lib/amd64/"libjavafx*.so \
           "${JAVA_HOME}/jre/lib/amd64/"libjfx*.so && \
    rm -rf "${JAVA_HOME}/jre/bin/jjs" \
           "${JAVA_HOME}/jre/bin/keytool" \
           "${JAVA_HOME}/jre/bin/orbd" \
           "${JAVA_HOME}/jre/bin/pack200" \
           "${JAVA_HOME}/jre/bin/policytool" \
           "${JAVA_HOME}/jre/bin/rmid" \
           "${JAVA_HOME}/jre/bin/rmiregistry" \
           "${JAVA_HOME}/jre/bin/servertool" \
           "${JAVA_HOME}/jre/bin/tnameserv" \
           "${JAVA_HOME}/jre/bin/unpack200" \
           "${JAVA_HOME}/jre/lib/ext/nashorn.jar" \
           "${JAVA_HOME}/jre/lib/jfr.jar" \
           "${JAVA_HOME}/jre/lib/jfr" \
           "${JAVA_HOME}/jre/lib/oblique-fonts" && \
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
        "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" -O /tmp/jce_policy-8.zip && \
    unzip -jo -d "${JAVA_HOME}/jre/lib/security" "/tmp/jce_policy-8.zip" && \
    apk del build-dependencies && \
    rm /tmp/* && chown -R ${USERNAME}:${GROUPNAME} /usr/lib/jvm

###############################
### INSTALL SONARQUBE 6.3.1 ###
###############################
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE && \
    mkdir /opt && cd /opt && \
    wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VER}.zip && \
    wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VER}.zip.asc && \
    gpg --batch --verify sonarqube.zip.asc sonarqube.zip && \
    unzip sonarqube.zip && \
    mv sonarqube-${SONAR_VER} sonarqube && \
    rm sonarqube.zip* && \
    rm -rf ${SONARQUBE_HOME}/bin/*


VOLUME ${SONARQUBE_HOME}/data
EXPOSE 9000
WORKDIR ${SONARQUBE_HOME}
COPY run.sh ${SONARQUBE_HOME}/bin/
CMD ./bin/run.sh
