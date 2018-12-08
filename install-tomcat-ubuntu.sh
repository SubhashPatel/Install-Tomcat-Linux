#!/bin/bash

#######################################
# Bash script to install a Tomcat in ubuntu
# Author: Subhash (serverkaka.com)

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Prerequisite
apt-get install unzip -y

# Install Java if not allready Installed
if java -version | grep -q "java version" ; then
  echo "Java Installed"
else
  sudo add-apt-repository ppa:webupd8team/java -y  && sudo apt-get update -y  && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && sudo apt-get install oracle-java8-installer -y && echo JAVA_HOME=/usr/lib/jvm/java-8-oracle >> /etc/environment && echo JRE_HOME=/usr/lib/jvm/java-8-oracle/jre >> /etc/environment && source /etc/environment
fi

# Install Tomcat
cd /opt/
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.8/bin/apache-tomcat-9.0.8.zip
unzip apache-tomcat-9.0.8.zip

# Set Permission for execute
chown -RH tomcat: /opt/apache-tomcat-9.0.8
chmod o+x /opt/apache-tomcat-9.0.8/bin/*.sh

# Adjust the Firewall
ufw allow 8080/tcp

# Create Service files
echo [Unit] >> /etc/systemd/system/tomcat.service
echo Description=Tomcat 9 servlet container >> /etc/systemd/system/tomcat.service
echo After=network.target >> /etc/systemd/system/tomcat.service
echo  >> /etc/systemd/system/tomcat.service
echo [Service] >> /etc/systemd/system/tomcat.service
echo Type=forking >> /etc/systemd/system/tomcat.service
echo  >> /etc/systemd/system/tomcat.service
echo User=root >> /etc/systemd/system/tomcat.service
echo Group=root >> /etc/systemd/system/tomcat.service
echo  >> /etc/systemd/system/tomcat.service
echo Environment="JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/systemd/system/tomcat.service
echo Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true" >> /etc/systemd/system/tomcat.service
echo  >> /etc/systemd/system/tomcat.service
echo Environment="CATALINA_BASE=/opt/apache-tomcat-9.0.8" >> /etc/systemd/system/tomcat.service
echo Environment="CATALINA_HOME=/opt/apache-tomcat-9.0.8" >> /etc/systemd/system/tomcat.service
echo Environment="CATALINA_PID=/opt/apache-tomcat-9.0.8/temp/tomcat.pid" >> /etc/systemd/system/tomcat.service
echo Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC" >> /etc/systemd/system/tomcat.service
echo  >> /etc/systemd/system/tomcat.service
echo ExecStart=/opt/apache-tomcat-9.0.8/bin/startup.sh >> /etc/systemd/system/tomcat.service
echo ExecStop=/opt/apache-tomcat-9.0.8/bin/shutdown.sh >> /etc/systemd/system/tomcat.service
echo  >> /etc/systemd/system/tomcat.service
echo [Install] >> /etc/systemd/system/tomcat.service
echo WantedBy=multi-user.target >> /etc/systemd/system/tomcat.service

# Start tomcat
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl status tomcat

# Set auto start tomcat as a system boot
sudo systemctl enable tomcat

# Clean downloades files
rm apache-tomcat-9.0.8.zip
apt-get autoremove

echo Tomcat is successfully installed at /opt/apache-tomcat-9.0.8
echo "you can start and stop tomcat using command : sudo service tomcat stop|start|status|restart" 
