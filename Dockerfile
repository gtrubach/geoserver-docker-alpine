FROM tomcat:9-jre8-alpine

ARG GEOSERVER_VERSION=2.15.0

ARG GEOSERVER_WAR_URL=http://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip

ENV GEOSERVER_DATA_DIR=/opt/geoserver/data_dir \
    GEOSERVER_LOG_LOCATION=${GEOSERVER_DATA_DIR}/logs/geoserver.log \
    GEOWEBCACHE_CACHE_DIR=${GEOSERVER_DATA_DIR}/gwc 

WORKDIR /geoserver

RUN apk update && apk add wget unzip ttf-dejavu && rm -rf /var/cache/apk/*

RUN wget ${GEOSERVER_WAR_URL} -O /tmp/geoserver-${GEOSERVER_VERSION}-war.zip \
    && unzip /tmp/geoserver-${GEOSERVER_VERSION}-war.zip -d /tmp/geoserver \
    && unzip /tmp/geoserver/geoserver.war -d ${CATALINA_HOME}/webapps/geoserver \
    && rm -r /tmp/* \
    && rm -r ${CATALINA_HOME}/webapps/geoserver/data/data/* \
    && rm -r ${CATALINA_HOME}/webapps/geoserver/data/workspaces/* \
    && rm -r ${CATALINA_HOME}/webapps/geoserver/data/layergroups/* \
    && mkdir -p ${GEOSERVER_DATA_DIR} \
    && mv ${CATALINA_HOME}/webapps/geoserver/data/* ${GEOSERVER_DATA_DIR} \
    && rm -r ${CATALINA_HOME}/webapps/geoserver/data

## Install MySQL extension
RUN wget "https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-mysql-plugin.zip" -O /tmp/mysql.zip \
    && unzip /tmp/mysql.zip -d /tmp/plugins \
    && mv /tmp/plugins/*.jar ${CATALINA_HOME}/webapps/geoserver/WEB-INF/lib/ \
    && rm -r /tmp/*

ENTRYPOINT ["catalina.sh", "run"]