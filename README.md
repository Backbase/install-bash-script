# Backbase IPS and CX6 installation via bash script

![Alt Text](install.gif)

## Description

This repository contains a bash script to install IPS and CX6 Backbase services in an automated way, from the download
of all the software needed until the import of the CX Manager experience all the step happen automatically one after the
other.
By default, everything is installed in a /tmp folder.

The steps followed in the script are:

* _setConstants_ - set the different constants needed: versions, paths, etc
* _initMysql_ - delete and create CX6 databases
* _buildCXFileSystemDir_ - create directories in the filesystem
* _importCertificate_ - import certificates
* _configTomcatInstances_ - copy Tomcat configuration
* _downloadAll_ - download Tomcat, ActiveMQ, IPS and CX6 services
* _installAndConfigLocalActiveMQ_ - install and configure ActiveMQ port 61616
* _installAndConfigLocalTomcat_ - install and configure the different Tomcats
  * Starting CX6 IPS Tomcat HTTP : 8080
  * Starting CX6 Portal Tomcat HTTP : 8081
  * Starting CX6 Editorial Tomcat HTTP : 8082
* _installLocalCx6_ - install and configure CX6 and IPS services
* _startAllCX6_ - start all Tomcats
* _fn_check_health_ "auth" - check health endpoints
* _fn_check_health_ "portal"
* _fn_check_health_ "contentservices"
* _fn_check_health_ "provisioning"
* _provisionCX6ExpMgr_ - provision editorial collection, web-sdk and cx-manager experience using cx importer tool


## Requirements

1. Internet access

2. Unix machine

3. Access to [Backbase Maven repositories](https://repo.backbase.com/) (to be able to download the dependencies)

4. [MySQL](https://www.mysql.com/downloads/) 5.6 or 5.7 running (root password must be 'backbase')
Make sure you copy the needed config, an example [here](common/mysql-configs/my.cnf)
```
sudo mkdir -p /usr/local/mysql/etc/
sudo cp ../common/mysql-configs/my.cnf /usr/local/mysql/etc/
```

5. Make sure you have [wget](https://www.gnu.org/software/wget/) installed:

For MacOS you can use
```
brew install wget
```

Ubuntu
```
apt-get install wget
```

RHEL / CentOS / Fedora
```
yum install wget
```

## Setup
A MySQL database version 5.6 or 5.7 needs to be up&running
Ports 61616, 8080, 8081 and 8082 need to be free


## Configuration

All the configurations needed for the different components: ActiveMQ, MySQL, Tomcat and the different services are 
inside the common folder

- [ActiveMQ Config](common/activemq-configs)
- [MySQL Config](common/mysql-configs)
- [Tomcat Structure](common/tomcat-structure)
- [Tomcat Configs](common/tomcat-configs)
- [Services Configs](common/service-configs)

## Running the script

    cd unix
    sh installcx6.sh
    
All the steps happen automatically, just wait for the script finish.
Progress can be monitored:
http://localhost:8080/registry/

When the scripts finished CX Manager should be available here:
http://localhost:8080/gateway/api/cxp-manager/login

## Road Map

A similar script Windows compatible


## How to contribute
Master branch is the stable branch and contains the latest released version
Develop is the "work in progress" branch, we will have the next snapshot version or any new functionality to test, 
can be unstable
For previous versions of the product we will have tags, in the format: v6.0.24

We follow gitflow for the contributions so, if there's a bug, open a PR against the branch you want to fix 
with the format:

    bugfix/small_description

If there's a new feature or functionality we want to add:

    feature/small_description
    
## Issues

Feel free to report issues https://github.com/Backbase/install-bash-script/issues

## Owners

Andrés Torres [email](mailto:andres@backbase.com)
