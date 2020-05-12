#!/usr/bin/env bash

function setConstants {

  export PATH=$PATH:/usr/local/mysql/bin
  export BACKBASE_HOME="/tmp/opt/backbase"

  IPS_VERSION=1.11.8
  IPS_URL=https://repo.backbase.com/backbase-6-release/com/backbase/platform-bom/${IPS_VERSION}/platform-bom-${IPS_VERSION}.zip
  AUTH_VERSION=1.4.0
  AUTH=https://repo.backbase.com/backbase-6-release/com/backbase/infra/authentication-dev/${AUTH_VERSION}/authentication-dev-${AUTH_VERSION}.war

  CX6_VERSION=6.2.4

  WEB_SDK_VERSION=1.11.0
  APPROVAL_VERSION=1.1.1
  WEB_SDK_URL=https://repo.backbase.com/expert-release-local/com/backbase/web-sdk/collection/collection-bb-web-sdk/${WEB_SDK_VERSION}/collection-bb-web-sdk-${WEB_SDK_VERSION}.zip
  IMPORTER_JAR_URL=https://repo.backbase.com/backbase-6-release/com/backbase/tools/cx/cx6-import-tool-cli/${CX6_VERSION}/cx6-import-tool-cli-${CX6_VERSION}.jar

  TOMCAT_VERSION=8.5.51
  TOMCAT_FILENAME=apache-tomcat-${TOMCAT_VERSION}.tar.gz
  TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/${TOMCAT_FILENAME}

  ACTIVEMQ_VERSION=5.15.12
  ACTIVEMQ_FILENAME=apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz
  ACTIVEMQ_URL=https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILENAME}

  CX6_HOME=${BACKBASE_HOME}

  CX6_FS_HOME=${CX6_HOME}/filesystem

  CX6_CONFIGS_HOME=${CX6_HOME}/service-configs

  CX6_TOMCAT=${CX6_HOME}/runtimes/tomcat
  CX6_ACTIVEMQ=${CX6_HOME}/runtimes/activemq

  CX6_TOMCAT_BASE=${CX6_TOMCAT}/${TOMCAT_VERSION}
  CX6_TOMCAT_PLATFORM=${CX6_TOMCAT}/platform
  CX6_TOMCAT_EDITORIAL=${CX6_TOMCAT}/editorial
  CX6_TOMCAT_PORTAL=${CX6_TOMCAT}/portal

  CX6_SSL_CERTS=${CX6_TOMCAT}/ssl-certs

  echo "Setting Script Constants..."
  echo "    -Tomcat   : $TOMCAT_VERSION"
  echo "    -ActiveMQ : $ACTIVEMQ_VERSION"
  echo "    -Base Path: $CX6_HOME"
  echo "    -CX6      : $CX6_VERSION"
  echo "    -IPS      : $IPS_VERSION"
}

function initMysql {
  mysql -u root -pbackbase < ../common/mysql-configs/cx6_schemas.sql
}

function downloadAll {
    pushd ../local-install
    echo "Downloading ActiveMQ"
    wget -Nt 1 ${ACTIVEMQ_URL}
    echo "Downloading Tomcat"
    wget -Nt 1 ${TOMCAT_URL}
    echo "Downloading additional Tomcat libraries (geronimo, mysql)"
    wget -Nt 1 https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.44/mysql-connector-java-5.1.44.jar
    wget -Nt 1 https://repo1.maven.org/maven2/org/apache/geronimo/specs/geronimo-jms_1.1_spec/1.1.1/geronimo-jms_1.1_spec-1.1.1.jar

    read -p "repo.backbase.com username: " AR_USERNAME
    read -s -p "repo.backbase.com password: " AR_PASSWORD

    echo "Downloading CX6 BOM File"
    mvn org.apache.maven.plugins:maven-dependency-plugin:get -Dpackaging=pom -DrepoUrl=https://repo.backbase.com -Dartifact=com.backbase.cxp:cx-bom:${CX6_VERSION} -Ddest=.
    echo "Downloading IPS BOM File"
    mvn org.apache.maven.plugins:maven-dependency-plugin:get -Dpackaging=pom -DrepoUrl=https://repo.backbase.com -Dartifact=com.backbase:platform-bom:${IPS_VERSION} -Ddest=.
    echo "Downloading IPS WAR files"
    mvn -f platform-bom-${IPS_VERSION}.pom package -DoutputDirectory=. -DexcludeTransitive=true
    echo "Downloading CX6 WAR files"
    mvn dependency:copy-dependencies -P war-files -Dmdep.stripVersion=true -DoutputDirectory=. -DexcludeTransitive=true -f cx-bom-${CX6_VERSION}.pom
    echo "Downloading CX6 SQL files"
    mvn dependency:copy-dependencies -P sql-scripts -Dmdep.stripVersion=true -DoutputDirectory=./sqlscripts -Dclassifier=sql -DexcludeTransitive=true -f cx-bom-${CX6_VERSION}.pom
    echo "Downloading CX6 Experience Manager"
    mvn dependency:copy-dependencies -P experience-manager -Dmdep.stripVersion=true -DoutputDirectory=. -DexcludeTransitive=true -f cx-bom-${CX6_VERSION}.pom
    echo "Downloading CX6 Editorial Collection"
    mvn dependency:copy-dependencies -P editorial-collection  -Dmdep.stripVersion=true -DoutputDirectory=. -DexcludeTransitive=true -f cx-bom-${CX6_VERSION}.pom
    echo "Downloading Approvals"
    mvn dependency:get -Dartifact=com.backbase.cxp:collection-approvals:${APPROVAL_VERSION}:zip:portal -Ddest=.
    mvn dependency:get -Dartifact=com.backbase.cxp:collection-approvals:${APPROVAL_VERSION}:zip:page -Ddest=.
    echo "Downloading Web SDK"
    wget -N --http-user=${AR_USERNAME} --http-password=${AR_PASSWORD} ${WEB_SDK_URL}
    echo "Downloading Importer Jar Tool"
    mvn dependency:copy-dependencies -P tools  -Dmdep.stripVersion=true -DoutputDirectory=. -DexcludeTransitive=true -f cx-bom-${CX6_VERSION}.pom
    echo "Downloading Authentication Dev Service"
    wget -N --http-user=${AR_USERNAME} --http-password=${AR_PASSWORD} ${AUTH}
    popd
}

function buildCXFileSystemDir {
  echo "Building CX filesystem directory structure in ${CX6_HOME}"
  mkdir -p ${CX6_CONFIGS_HOME}
  cp -R ../common/service-configs/* ${CX6_CONFIGS_HOME}

  mkdir -p ${CX6_FS_HOME}/portal/content
  mkdir -p ${CX6_FS_HOME}/contentservices/{content,imports,exports,file}
  mkdir -p ${CX6_FS_HOME}/publishing/{exports,imports}
  chmod -R 777 ${CX6_FS_HOME}/

  echo "Building CX Tomcat directory structure"
  mkdir -p ${CX6_TOMCAT_BASE}
  mkdir -p ${CX6_TOMCAT_PLATFORM}
  mkdir -p ${CX6_TOMCAT_EDITORIAL}
  mkdir -p ${CX6_TOMCAT_PORTAL}
  mkdir -p ${CX6_SSL_CERTS}
  chmod -R 775 ${CX6_TOMCAT}

  echo "Building ActiveMQ directory structure"
  mkdir -p ${CX6_ACTIVEMQ}

  chown -R $USER ${CX6_HOME}/

  cp ./startcx6.sh ${CX6_HOME}/
  cp ./stopcx6.sh ${CX6_HOME}/
  chmod +x ${CX6_HOME}/*.sh
}

function importCertificate {
  $JAVA_HOME/bin/keytool -importcert -noprompt -alias tomcat -file ../common/tomcat.crt -keystore ${CX6_SSL_CERTS}/tomcat.jks -storepass changeit
}

function configTomcatInstances {
  echo "Configuring CX6 Tomcat instances"
  cp -Rf ../common/tomcat-structure/* ${CX6_TOMCAT_EDITORIAL}
  cp -Rf ../common/tomcat-structure/* ${CX6_TOMCAT_PLATFORM}
  cp -Rf ../common/tomcat-structure/* ${CX6_TOMCAT_PORTAL}
  cp -Rf ../common/tomcat.p12 ${CX6_SSL_CERTS}/

  cp -Rf ../common/tomcat-configs/editorial/* ${CX6_TOMCAT_EDITORIAL}
  cp -Rf ../common/tomcat-configs/platform/* ${CX6_TOMCAT_PLATFORM}
  cp -Rf ../common/tomcat-configs/portal/* ${CX6_TOMCAT_PORTAL}
}

function installAndConfigLocalActiveMQ {
  echo "Installing ActiveMQ version v${ACTIVEMQ_VERSION}"
  TEMP_DIR=$(mktemp -d)
  echo "Copying local ActiveMQ"
  cp -f ../local-install/${ACTIVEMQ_FILENAME} ${TEMP_DIR}
  pushd ${TEMP_DIR}
  tar -xzf ${ACTIVEMQ_FILENAME}
  cp -Rf apache-activemq-${ACTIVEMQ_VERSION}/* ${CX6_ACTIVEMQ}
  popd
  rm -rf ${TEMP_DIR}

  cp ../common/activemq-configs/activemq.xml ${CX6_ACTIVEMQ}/conf
}

function installAndConfigLocalTomcat {
  echo "Installing base Tomcat version v${TOMCAT_VERSION}"
  TEMP_DIR=$(mktemp -d)
  echo "Copying local Tomcat"
  cp -f ../local-install/${TOMCAT_FILENAME} ${TEMP_DIR}
  cp -f ../local-install/mysql-connector-java-5.1.44.jar ${TEMP_DIR}
  cp -f ../local-install/geronimo-jms_1.1_spec-1.1.1.jar ${TEMP_DIR}

  pushd ${TEMP_DIR}
  tar -xzf ${TOMCAT_FILENAME}
  cp -Rf apache-tomcat-${TOMCAT_VERSION}/* ${CX6_TOMCAT_BASE}

  echo "Installing additional Tomcat libraries (geronimo, mysql)"
  cp -f mysql-connector-java-5.1.44.jar ${CX6_TOMCAT_BASE}/lib
  cp -f geronimo-jms_1.1_spec-1.1.1.jar ${CX6_TOMCAT_BASE}/lib
  popd
  rm -rf ${TEMP_DIR}

  cp ../common/tomcat-configs/setenv.sh ${CX6_TOMCAT_BASE}/bin
}

function installLocalCx6 {

  TEMP_DIR=$(mktemp -d)

  cp -f ../local-install/*.war ${TEMP_DIR}
  cp -f ../local-install/sqlscripts/*.zip ${TEMP_DIR}

  pushd ${TEMP_DIR}
  mkdir db-scripts
  unzip \*.zip -d db-scripts

  echo "Copying Editorial WARs"
  cp auditing.war ${CX6_TOMCAT_EDITORIAL}/webapps
  cp renditionservice.war ${CX6_TOMCAT_EDITORIAL}/webapps
  cp targeting.war ${CX6_TOMCAT_EDITORIAL}/webapps
  cp thumbnailservice.war ${CX6_TOMCAT_EDITORIAL}/webapps
  cp space-controller-service.war ${CX6_TOMCAT_EDITORIAL}/webapps

  echo "Copying IPS WARs"
  cp authentication-dev-1.4.0.war ${CX6_TOMCAT_PLATFORM}/webapps/authentication.war
  cp gateway.war ${CX6_TOMCAT_PLATFORM}/webapps/gateway.war
  cp registry.war ${CX6_TOMCAT_PLATFORM}/webapps
  cp token-converter.war ${CX6_TOMCAT_PLATFORM}/webapps

  echo "Copying Portal WARs"
  cp contentservices.war ${CX6_TOMCAT_PORTAL}/webapps
  cp portal.war ${CX6_TOMCAT_PORTAL}/webapps
  cp provisioning.war ${CX6_TOMCAT_PORTAL}/webapps

  createDatabases

  popd
  rm -rf ${TEMP_DIR}
}

function createDatabases {
  echo "Creating CXS databases"
  mysql -u root -pbackbase auditing_e < db-scripts/auditing/mysql/create/auditing.sql
  mysql -u root -pbackbase cs_e < db-scripts/contentservices/mysql/create/contentservices.sql
  mysql -u root -pbackbase portal_e < db-scripts/portal/mysql/create/portal.sql
  mysql -u root -pbackbase provisioning_e < db-scripts/provisioning/mysql/create/provisioning.sql
  mysql -u root -pbackbase rendition_e< db-scripts/renditionservice/mysql/create/renditionservice.sql
  mysql -u root -pbackbase tar_e < db-scripts/targeting/mysql/create/targeting.sql
  mysql -u root -pbackbase spacecontroller_e < db-scripts/space-controller/mysql/create/space-controller.sql
}

function startActiveMQ {
  echo "Starting ActiveMQ"
  echo "  TCP : 61616"
  echo "  SSL : 61617"
  bash ${CX6_ACTIVEMQ}/bin/activemq start
}

function startPlatform {
  echo "Starting CX6 IPS Tomcat"
  echo "  HTTP : 8080"
  echo "  JDWP : 8020"
  echo "   JMX : 8050"
  bash ${CX6_TOMCAT_PLATFORM}/startup.sh
}

function startPortal {
  echo "Starting CX6 Portal Tomcat"
  echo "  HTTP : 8081"
  echo "  JDWP : 8021"
  echo "   JMX : 8051"
  bash ${CX6_TOMCAT_PORTAL}/startup.sh
}

function startEditorial {
  echo "Starting CX6 Editorial Tomcat"
  echo "  HTTP : 8082"
  echo "  JDWP : 8022"
  echo "   JMX : 8052"
  bash ${CX6_TOMCAT_EDITORIAL}/startup.sh
}

function startAllCX6 {
  startActiveMQ
  startPlatform
  startPortal
  sleep 30
  startEditorial
  sleep 30
}

function provisionCX6ExpMgr {

  TEMP_DIR=$(mktemp -d)
  cp ../local-install/editorial-collection.zip ${TEMP_DIR}
  cp ../local-install/experience-manager.zip ${TEMP_DIR}
  cp ../local-install/collection-bb-web-sdk-${WEB_SDK_VERSION}.zip ${TEMP_DIR}
  cp ../local-install/cx6-import-tool-cli.jar ${TEMP_DIR}
  cp ../local-install/collection-approvals-0.0.17-portal.zip ${TEMP_DIR}
  cp ../local-install/collection-approvals-0.0.17-page.zip ${TEMP_DIR}
  pushd ${TEMP_DIR}

  echo "Provision Editorial Collection"
  # Provision Editorial Collection
  java -jar cx6-import-tool-cli.jar --import editorial-collection.zip --username admin --password admin --target-ctx http://localhost:8080/gateway/api/provisioning --auth-url=http://localhost:8080/gateway/api/auth/login
  echo "Provision Web SDK"
  # Provision web-sdk
  java -jar cx6-import-tool-cli.jar --import collection-bb-web-sdk-${WEB_SDK_VERSION}.zip --username admin --password admin --target-ctx http://localhost:8080/gateway/api/provisioning --auth-url=http://localhost:8080/gateway/api/auth/login
  # Import the Experience Manager
  echo "Provision Experience Manager"
  java -jar cx6-import-tool-cli.jar --import experience-manager.zip --username admin --password admin --target-ctx http://localhost:8080/gateway/api/provisioning --auth-url=http://localhost:8080/gateway/api/auth/login
  # Provision Approvals Collection and its portal
  echo "Provision Approvals (collection and portal)"
  java -jar cx6-import-tool-cli.jar --import collection-approvals-${APPROVAL_VERSION}-page.zip --username admin --password admin --target-ctx http://localhost:8080/gateway/api/provisioning --auth-url=http://localhost:8080/gateway/api/auth/login
  java -jar cx6-import-tool-cli.jar --import collection-approvals-${APPROVAL_VERSION}-portal.zip --username admin --password admin --target-ctx http://localhost:8080/gateway/api/provisioning --auth-url=http://localhost:8080/gateway/api/auth/login

  popd
  rm -rf ${TEMP_DIR}
}

function fn_check_health {
    local ENDPOINT=$1
    local TRY_COUNTER=0
    local RESPONSE=

    echo "=========================== Checking $ENDPOINT availability ==========================="

    while ([ "$RESPONSE" != '200' ] && [ "$TRY_COUNTER" -lt 50 ])
    do
        echo "Ping localhost:8080/gateway/api/$ENDPOINT .... try $TRY_COUNTER"
        RESPONSE=$(curl -s -o /dev/null -I -w "%{http_code}" --max-time 3 --connect-timeout 3 "localhost:8080/gateway/api/$ENDPOINT")
        echo "$RESPONSE"
        let "TRY_COUNTER=TRY_COUNTER+1"

        if [ "$RESPONSE" != '200' ]; then
            sleep 30
        fi
    done

    if [ "$RESPONSE" != '200' ]; then
        echo "localhost:8080/gateway/api/$ENDPOINT is not ready after $TRY_COUNTER tries"
        exit 1
    fi
}

setConstants
initMysql
buildCXFileSystemDir
importCertificate
configTomcatInstances
downloadAll
installAndConfigLocalActiveMQ
installAndConfigLocalTomcat
installLocalCx6
startAllCX6
fn_check_health "auth/actuator/health"
fn_check_health "portal/actuator/health/liveness"
fn_check_health "contentservices/actuator/health/liveness"
fn_check_health "provisioning/actuator/health/liveness"
provisionCX6ExpMgr
