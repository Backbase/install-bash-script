#!/bin/sh

CURRENT_DIR=`dirname $0`

export CATALINA_HOME=/tmp/opt/backbase/runtimes/tomcat/8.5.51
export CATALINA_BASE=$CURRENT_DIR

LOCAL_REGISTRY_IP="-Deureka.instance.hostname=localhost"
LOCAL_REGISTRY_PORT="-Deureka.instance.nonSecurePort=8080"

JVM_DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,address=8020,server=y,suspend=n"
JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8050 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=localhost"

# Include in JAVA_OPTS to change logging level
LOGGING_DEBUG="-Dlogging.level=DEBUG"

MEM_MAX="512"
if [[ ! -z "${MEM_MAX}" ]]; then
    MEM="-Xms128m -Xmx${MEM_MAX}m"
else
    MEM=""
fi

#EUREKA_SERVICE_URL="-Deureka.client.serviceUrl.defaultZone=http://localhost:8080/registry/eureka/"
export SPRING_APPLICATION_JSON='{"eureka.client.serviceUrl.defaultZone": "http://localhost:8080/registry/eureka/"}'
export GATEWAY_TOKEN_CONVERTER_URL="http://token-converter/token-converter/convert"
export GATEWAY_TOKEN_CONVERTER_LOADBALANCED="true"
export JAVA_OPTS="$JAVA_OPTS $MEM $EUREKA_SERVICE_URL $LOCAL_REGISTRY_IP $LOCAL_REGISTRY_PORT $JMX $JVM_DEBUG"

$CATALINA_HOME/bin/catalina.sh start
