This text copied from http://v2p2dev.to.cnr.it/doku.php?id=repo371:base
Note that my fedora class does NOT use this exclusively!  My class is 
built largely from the instructions at 
https://wiki.duraspace.org/display/ISLANDORA713/Installing+Fedora
------------------------------------------------------------------------ 

Base system (Ubuntu 12.04, Tomcat7, Java JDK 7, Fedora Commons 3.7.1)

Ubuntu server 12.04.4 LTS (2014/02/20)
JAVA JDK 7
apt-get install python-software-properties
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java7-installer
\\
# java -version
java version "1.7.0_51"
Java(TM) SE Runtime Environment (build 1.7.0_51-b13)
Java HotSpot(TM) 64-Bit Server VM (build 24.51-b03, mixed mode)
MySQL 5.5
apt-get install mysql-server libmysql-java
Tomcat 7
apt-get install tomcat7 tomcat7-admin tomcat7-common

nano -w /etc/default/tomcat7
     JAVA_HOME=/usr/lib/jvm/java-7-oracle
     ###JAVA_OPTS="-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC"
     JAVA_OPTS="-Djava.awt.headless=true -Xmx1g -Xms128m"
     JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC -XX:MaxPermSize=256m"

nano -w /etc/tomcat7/tomcat-users.xml

	<tomcat-users>         
         <role rolename="admin-gui"/>
         <role rolename="admin-script"/>
         <role rolename="manager-gui"/>
         <role rolename="manager-script"/>
         <role rolename="manager-jmx"/>
	 <user username="*****" password="******" roles="admin-gui,admin-script,manager-gui,manager-script,manager-jmx"/> 
	</tomcat-users>

service tomcat7 start
Fedora Commons 3.7.1 (llstorage on dedicated partition)
mkdir /usr/local/fedora
mkdir /srv/data
chown -R tomcat7:tomcat7 /usr/local/fedora
chown -R tomcat7:tomcat7 /srv/data

nano -w /etc/default/tomcat7
	# Stuff for Fedora Commons
	export FEDORA_HOME=/usr/local/fedora
	PATH=$FEDORA_HOME/server/bin:$FEDORA_HOME/client/bin:$JAVA_HOME/bin:$PATH
service tomcat7 restart

mysql -u root -p
	CREATE DATABASE v2p2repo;
	GRANT ALL ON v2p2repo.* TO fedoraAdmin@localhost IDENTIFIED BY '***';
	GRANT ALL ON v2p2repo.* TO fedoraAdmin@'%' IDENTIFIED BY '***';
	FLUSH PRIVILEGES;

wget http://garr.dl.sourceforge.net/project/fedora-commons/fedora/3.7.1/fcrepo-installer-3.7.1.jar
service tomcat7 stop

java -jar fcrepo-installer-3.7.1.jar
***********************
  Fedora Installation
***********************

To install Fedora, please answer the following questions.
Enter CANCEL at any time to abort the installation.
Detailed installation instructions are available online:

            https://wiki.duraspace.org/display/FEDORA/All+Documentation

Installation type
-----------------
The 'quick' install is designed to get you up and running with Fedora
as quickly and easily as possible. It will install Tomcat and an
embedded version of the Derby database. SSL support and XACML policy
enforcement will be disabled.
For more options, including the choice of hostname, ports, security,
and databases, select 'custom'.
To install only the Fedora client software, enter 'client'.

Options : quick, custom, client

Enter a value ==> custom


Fedora home directory
---------------------
This is the base directory for Fedora scripts, configuration files, etc.
Enter the full path where you want to install these files.

Enter a value ==> /usr/local/fedora

WARNING: The environment variable, FEDORA_HOME, is not defined
WARNING: Remember to define the FEDORA_HOME environment variable
WARNING: before starting Fedora.

Fedora administrator password
-----------------------------
Enter the password to use for the Fedora administrator (fedoraAdmin) account.

Enter a value ==> ********


Fedora server host
------------------
The host Fedora will be running on.
If a hostname (e.g. www.example.com) is supplied, a lookup will be
performed and the IP address of the host (not the host name) will be used
in the default Fedora XACML policies.


Enter a value [default is localhost] ==> v2p2repo.to.cnr.it


Fedora application server context
---------------------------------
The application server context Fedora will be running in.
If 'fedora' (default) is supplied, the resulting context path
will be http://www.example.com/fedora.
It must be ensured that the configured application server context
matches this path if explicitly configured.


Enter a value [default is fedora] ==> fedora


Authentication requirement for API-A
------------------------------------
Fedora's management (API-M) interface always requires user authentication.
Require user authentication for Fedora's access (API-A) interface?

Options : true, false

Enter a value [default is false] ==> false


SSL availability
----------------
Should Fedora be available via SSL?  Note: this does not preclude
regular HTTP access; it just indicates that it should be possible for
Fedora to be accessed over SSL.

Options : true, false

Enter a value [default is true] ==> false


Servlet engine
--------------
Which servlet engine will Fedora be running in?
Enter 'included' to use the bundled Tomcat 6.0.35 server.
To use your own, existing installation of Tomcat, enter 'existingTomcat'.
Enter 'other' to use a different servlet container.

Options : included, existingTomcat, other

Enter a value [default is included] ==> existingTomcat

Tomcat home directory
---------------------
Please provide the full path to your existing Tomcat installation, or
the path where you plan to install the bundled Tomcat.

Enter a value ==> /var/lib/tomcat7

WARNING: The environment variable, CATALINA_HOME, is not defined
WARNING: Remember to define the CATALINA_HOME environment variable
WARNING: before starting Fedora.

Tomcat HTTP port
----------------
Which HTTP port (non-SSL) should Tomcat listen on?  This can be changed
later in Tomcat's server.xml file.


Enter a value [default is 8080] ==> 8080


Tomcat shutdown port
--------------------
Which port should Tomcat use for shutting down?  Make sure this doesn't
conflict with an existing service.  This can be changed later in Tomcat's
server.xml file.


Enter a value [default is 8005] ==> 8005


Database
--------
Please select the database you will be using with
Fedora. The supported databases are Derby, MySQL, Oracle and Postgres.
If you do not have a database ready for use by Fedora or would prefer to
use the embedded version of Derby bundled with Fedora, enter 'included'.

Options : derby, mysql, oracle, postgresql, included

Enter a value ==> mysql


MySQL JDBC driver
-----------------
You may either use the included JDBC driver or your own copy.
Enter 'included' to use the included JDBC driver, or, enter the location
(full path) of the driver.


Enter a value [default is included] ==> included


Database username
-----------------
Enter the database username Fedora will use to connect to the Fedora database.

Enter a value ==> fedoraAdmin


Database password
-----------------
Enter the database password Fedora will use to connect to the Fedora database.

Enter a value ==> *******


JDBC URL
--------
Please enter the JDBC URL.


Enter a value [default is jdbc:mysql://localhost/!!!!08!!!!?useUnicode=true&amp;characterEncoding=UTF-8&amp;autoReconnect=true] ==> jdbc:mysql://localhost/v2p2repo?useUnicode=true&amp;characterEncoding=UTF-8&amp;autoReconnect=true                                       

JDBC DriverClass
----------------
Please enter the JDBC driver class.


Enter a value [default is com.mysql.jdbc.Driver] ==> com.mysql.jdbc.Driver


Validating database connection...Successfully connected to MySQL
OK


Use upstream HTTP authentication (Experimental Feature)
-------------------------------------------------------
You may wish to rely on a local SSO or other external source for HTTP
authentication and subject attributes.
WARNING: This is an experimental feature and should be enabled only with the
understanding that integration with external authentication will require
further configuration and that this is not yet a stable Fedora feature.
We invite you to try it out and give us feedback.
Use upstream authentication?

Options : true, false

Enter a value [default is false] ==> false


Enable FeSL AuthZ (Experimental Feature)
----------------------------------------
Enable FeSL Authorization? This is an experimental replacement for Fedora's
legacy authorization module, and is still under development.
Production repositories should NOT enable this, but we invite you to try it
out and give us feedback.


Enter a value [default is false] ==> false


Policy enforcement enabled
--------------------------
Should XACML policy enforcement be enabled?  Note: This will put a set of
default security policies in play for your Fedora server.

Options : true, false

Enter a value [default is true] ==> true


Low Level Storage
-----------------
Which low-level (file) storage plugin do you want to use?
We recommend akubra-fs for new installs.  If you are upgrading Fedora from
version 3.3 or below, you should use legacy-fs for compatibility with your
existing storage.  Other plugins are also available, but they must be
configured after installation.

Options : akubra-fs, legacy-fs

Enter a value [default is akubra-fs] ==> akubra-fs

Enable Resource Index
---------------------
Enable the Resource Index?

Options : true, false

Enter a value [default is false] ==> true


Enable Messaging
----------------
Enable Messaging? Messaging sends notifications of API-M events via JMS.

Options : true, false

Enter a value [default is false] ==> true


Messaging Provider URI
----------------------
Please enter the messaging provider URI. For more information about
using ActiveMQ broker URIs, see
http://activemq.apache.org/broker-uri.html


Enter a value [default is vm:(broker:(tcp://localhost:61616))] ==> vm:(broker:(tcp://localhost:61616))

Deploy local services and demos
-------------------------------
Several sample back-end services are included with this distribution.
These are required if you want to use the demonstration objects.
If you'd like these to be automatically deployed, enter 'true'.
Otherwise, the installer will put the files in your FEDORA_HOME/install
directory in case you want to deploy them later.

Options : true, false

Enter a value [default is true] ==> false


Preparing FEDORA_HOME...
        Configuring fedora.fcfg
        Installing beSecurity
Will not overwrite existing /var/lib/tomcat7/conf/server.xml.
Wrote example server.xml to:
        /usr/local/fedora/install/server.xml
Preparing fedora.war...
Deploying fedora.war...
Installation complete.

----------------------------------------------------------------------
Before starting Fedora, please ensure that any required environment
variables are correctly defined
        (e.g. FEDORA_HOME, JAVA_HOME, JAVA_OPTS, CATALINA_HOME).
For more information, please consult the Installation & Configuration
Guide in the online documentation.
----------------------------------------------------------------------
cd /var/lib/tomcat7/conf/
cp server.xml server.xml.ORI
cp /usr/local/fedora/install/server.xml /var/lib/tomcat7/conf/server.xml

nano -w /var/lib/tomcat7/conf/server.xml
    <!-- Define an AJP 1.3 Connector on port 8009 -->
    <!--
    -->
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443"/>

nano -w /usr/local/fedora/server/config/spring/akubra-llstore.xml
nano -w /usr/local/fedora/server/fedora-internal-use/config/akubra-llstore.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN" "http://www.springframework.org/dtd/spring-beans.dtd">
<beans>

  <bean name="org.fcrepo.server.storage.lowlevel.ILowlevelStorage"
    class="org.fcrepo.server.storage.lowlevel.akubra.AkubraLowlevelStorageModule">
    <constructor-arg index="0">
      <map />
    </constructor-arg>
    <constructor-arg index="1" ref="org.fcrepo.server.Server" />
    <constructor-arg index="2" type="java.lang.String"
      value="org.fcrepo.server.storage.lowlevel.ILowlevelStorage" />
    <property name="impl"
      ref="org.fcrepo.server.storage.lowlevel.akubra.AkubraLowlevelStorage" />
  </bean>

  <bean
    name="org.fcrepo.server.storage.lowlevel.akubra.AkubraLowlevelStorage"
    class="org.fcrepo.server.storage.lowlevel.akubra.AkubraLowlevelStorage"
    singleton="true">
    <constructor-arg>
      <description>The store of serialized Fedora objects</description>
      <ref bean="objectStore" />
    </constructor-arg>
    <constructor-arg>
      <description>The store of datastream content</description>
      <ref bean="datastreamStore" />
    </constructor-arg>
    <constructor-arg value="true">
      <description>if true, replaceObject calls will be done in a way
        that
        ensures the old content is not deleted until the new content is safely
        written. If the objectStore already does this, this should be
        given as
        false</description>
    </constructor-arg>
    <constructor-arg value="true">
      <description>save as above, but for datastreamStore</description>
    </constructor-arg>
  </bean>

  <bean name="objectStore" class="org.akubraproject.map.IdMappingBlobStore"
    singleton="true">
    <constructor-arg value="urn:example.org:objectStore" />
    <constructor-arg>
      <ref bean="fsObjectStore" />
    </constructor-arg>
    <constructor-arg>
      <ref bean="fsObjectStoreMapper" />
    </constructor-arg>
  </bean>

  <bean name="fsObjectStore" class="org.akubraproject.fs.FSBlobStore"
    singleton="true">
    <constructor-arg value="urn:example.org:fsObjectStore" />
    <constructor-arg value="/srv/data/objectStore"/>
  </bean>

  <bean name="fsObjectStoreMapper"
    class="org.fcrepo.server.storage.lowlevel.akubra.HashPathIdMapper"
    singleton="true">
    <constructor-arg value="##" />
  </bean>

  <bean name="datastreamStore" class="org.akubraproject.map.IdMappingBlobStore"
    singleton="true">
    <constructor-arg value="urn:fedora:datastreamStore" />
    <constructor-arg>
      <ref bean="fsDatastreamStore" />
    </constructor-arg>
    <constructor-arg>
      <ref bean="fsDatastreamStoreMapper" />
    </constructor-arg>
  </bean>

  <bean name="fsDatastreamStore" class="org.akubraproject.fs.FSBlobStore"
    singleton="true">
    <constructor-arg value="urn:example.org:fsDatastreamStore" />
    <constructor-arg value="/srv/data/datastreamStore"/>
  </bean>

  <bean name="fsDatastreamStoreMapper"
    class="org.fcrepo.server.storage.lowlevel.akubra.HashPathIdMapper"
    singleton="true">
    <constructor-arg value="##" />
  </bean>

  <bean name="fedoraStorageHintProvider"
    class="org.fcrepo.server.storage.NullStorageHintsProvider"
    singleton="true">
  </bean>

</beans>
chown -R tomcat7:tomcat7 /usr/local/fedora
chown -R tomcat7:tomcat7 /srv/data

service tomcat7 start
service tomcat7 stop
Problem is due to UNIQUE KEY and KEY. Workaround - Execute CREATE TABLE manually and make rebuild key UNIQUE and PRIMARY:

CREATE TABLE fcrepoRebuildStatus (
  rebuildDate bigint NOT NULL,
  complete boolean NOT NULL,
  UNIQUE KEY rebuildDate (rebuildDate),
  PRIMARY KEY rebuildDate (rebuildDate)
);

service tomcat7 start