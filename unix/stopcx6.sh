#!/usr/bin/env bash

export BACKBASE_HOME="/tmp/opt/backbase"

bash $BACKBASE_HOME/runtimes/activemq/bin/activemq stop
bash $BACKBASE_HOME/runtimes/tomcat/editorial/shutdown.sh && $BACKBASE_HOME/runtimes/tomcat/portal/shutdown.sh && $BACKBASE_HOME/runtimes/tomcat/platform/shutdown.sh
