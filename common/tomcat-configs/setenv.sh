#!/usr/bin/env bash

export BACKBASE_HOME="/tmp/opt/backbase"
export BB_FS_HOME="${BACKBASE_HOME}/filesystem"
#export BACKBASE_ENVROLE="editorial"
#export BACKBASE_DBTYPE="mysql"

#the 128-bit key is used for inter-service communication and symmetric encryption
export SIG_SECRET_KEY=JWTSecretKeyDontUseInProduction!
export EXTERNAL_SIG_SECRET_KEY=JWTSecretKeyDontUseInProduction!
export EXTERNAL_ENC_SECRET_KEY=JWTEncKeyDontUseInProduction666!
export USERCTX_KEY=JWTSecretKeyDontUseInProduction!

# Message Broker env vars
export SPRING_ACTIVEMQ_BROKER_URL="tcp://localhost:61616"
export SPRING_ACTIVEMQ_USER="admin"
export SPRING_ACTIVEMQ_PASSWORD="admin"

# CX6 FileSystem Paths
export PORTAL_FILESYSTEM_CONTEXTROOT="${BB_FS_HOME}/portal/content"
export CONTENTSERVICES_CMIS_REPOSITORY_CONTENT_FILELOCATION="${BB_FS_HOME}/contentservices/content"
export CONTENTSERVICES_FILESYSTEM_IMPORTLOCATION="${BB_FS_HOME}/contentservices/imports"
export CONTENTSERVICES_FILESYSTEM_EXPORTLOCATION="${BB_FS_HOME}/contentservices/exports"
export CONTENTSERVICES_FILESYSTEM_FILELOCATION="${BB_FS_HOME}/contentservices/file"
export PUBLISHING_FILESYSTEM_IMPORT_LOCATION="${BB_FS_HOME}/publishing/imports"
export PUBLISHING_FILESYSTEM_EXPORT_LOCATION="${BB_FS_HOME}/publishing/exports"

#external token TTL values
export SSO_JWT_EXTERNAL_EXPIRATION=36000
export SSO_JWT_EXTERNAL_RENEW=144000
export SSO_JWT_EXTERNAL_NOT_VALID_AFTER=57600

#export LIQUIBASE_ENABLED="false"

export SPRING_APPLICATION_JSON='{"eureka.client.serviceUrl.defaultZone": "http://localhost:8080/registry/eureka/"}'


export JAVA_OPTS="$JAVA_OPTS -DBACKBASE_HOME=/tmp/opt/backbase"
