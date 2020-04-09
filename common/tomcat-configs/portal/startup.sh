#!/bin/sh

CURRENT_DIR=`dirname $0`

export CATALINA_HOME=/tmp/opt/backbase/runtimes/tomcat/8.5.51
export CATALINA_BASE=$CURRENT_DIR

LOCAL_REGISTRY_IP="-Deureka.instance.ipAddress=127.0.0.1"
LOCAL_REGISTRY_PORT="-Deureka.instance.nonSecurePort=8081"

JVM_DEBUG="-Xdebug -Xrunjdwp:transport=dt_socket,address=8021,server=y,suspend=n"
JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8051 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=localhost"

# Include in JAVA_OPTS to change logging level
LOGGING_DEBUG="-Dlogging.level=DEBUG"

MEM_MAX="2048"
if [[ ! -z "${MEM_MAX}" ]]; then
    MEM="-Xms128m -Xmx${MEM_MAX}m"
else
    MEM=""
fi

export JAVA_OPTS="$JAVA_OPTS $MEM $LOCAL_REGISTRY_IP $LOCAL_REGISTRY_PORT $JVM_DEBUG $JMX"

$CATALINA_HOME/bin/catalina.sh start
