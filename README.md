# bigbluebutton-ocp-wrapper

Changes to setup.sh:

    --- docker/setup.sh	2017-11-02 20:02:19.000000000 -0400
    +++ setup.sh	2017-11-02 19:56:55.000000000 -0400
    @@ -5,6 +5,10 @@
             sed -i "s<^[[:blank:]#]*\(${2}\).*<\1=${3}<" $1
     }
     
    +# make sure tomcat7 uses current uid and gid 0
    +sed -i 's/:106:107:/:'$(id -u)':0:/g' /etc/passwd
    +sed -i 's/TOMCAT7_GROUP=tomcat7/TOMCAT7_GROUP=root/g' /etc/default/tomcat7
    +
     # docker build -t ffdixon/play_win .
     # docker run -p 80:80/tcp -p 443:443/tcp -p 1935:1935/tcp -p 5066:5066/tcp -p 2202:2202 -p 32750-32768:32750-32768/udp --cap-add=NET_ADMIN ffdixon/play_win -h 192.168.0.130
     # docker run -p 80:80/tcp -p 443:443/tcp -p 1935:1935/tcp -p 5066:5066/tcp -p 2202:2202 -p 32750-32768:32750-32768/udp --cap-add=NET_ADMIN ffdixon/play_win -h 192.168.10.186
    @@ -45,12 +49,12 @@
     
     apt-get install -y bbb-demo && /etc/init.d/tomcat7 start
     while [ ! -f /var/lib/tomcat7/webapps/demo/bbb_api_conf.jsp ]; do sleep 1; done
    -sudo /etc/init.d/tomcat7 stop
    +/etc/init.d/tomcat7 stop
     
     
     # Setup loopback address so FreeSWITCH can bind WS-BIND-URL to host IP
     #
    -sudo ip addr add $HOST dev lo
    +ip addr add $HOST dev lo
     
     # Setup the BigBlueButton configuration files
     #

Changes to mod/tomcat7:

    --- docker/mod/tomcat7	2017-11-02 20:02:19.000000000 -0400
    +++ tomcat7	2017-11-02 19:58:52.000000000 -0400
    @@ -29,10 +29,10 @@
     DEFAULT=/etc/default/$NAME
     JVM_TMP=/tmp/tomcat7-$NAME-tmp
     
    -if [ `id -u` -ne 0 ]; then
    -	echo "You need root privileges to run this script"
    -	exit 1
    -fi
    +#if [ `id -u` -ne 0 ]; then
    +#	echo "You need root privileges to run this script"
    +#	exit 1
    +#fi
      
     # Make sure tomcat is started with system locale
     if [ -r /etc/default/locale ]; then
    @@ -51,7 +51,7 @@
     
     # Run Tomcat 7 as this user ID and group ID
     TOMCAT7_USER=tomcat7
    -TOMCAT7_GROUP=tomcat7
    +TOMCAT7_GROUP=root
     
     # this is a work-around until there is a suitable runtime replacement 
     # for dpkg-architecture for arch:all packages

Changes to supervisord.conf:

    --- docker/supervisord.conf	2017-11-02 20:31:57.000000000 -0400
    +++ supervisord.conf	2017-11-02 20:36:15.000000000 -0400
    @@ -7,7 +7,8 @@
     [program:redis-server]
     startsecs = 0
     autorestart = false
    -#user=redis
    +user=tomcat7
    +group=root
     command=/usr/bin/redis-server /etc/redis/redis.conf
     stdout_logfile=/var/log/redis/stdout.log
     stderr_logfile=/var/log/redis/stderr.log
    @@ -15,34 +16,39 @@
     [program:nginx]
     startsecs = 0
     autorestart = false
    +user=tomcat7
    +group=root
     command=/usr/sbin/nginx -g "daemon off;"
     
     [program:freeswitch]
     startsecs = 0
     autorestart = false
    -user=freeswitch
    -group=daemon
    +user=tomcat7
    +group=root
     directory=/opt/freeswitch
     command=/opt/freeswitch/bin/freeswitch -nc -nf -core -nonat
     
     [program:bbb-apps-akka]
     startsecs = 0
     autorestart = false
    -user=bigbluebutton
    +user=tomcat7
    +group=root
     directory=/usr/share/bbb-apps-akka
     command=/usr/share/bbb-apps-akka/bin/bbb-apps-akka
     
     [program:bbb-fsesl-akka]
     startsecs = 0
     autorestart = false
    -user=bigbluebutton
    +user=tomcat7
    +group=root
     directory=/usr/share/bbb-fsesl-akka
     command=/usr/share/bbb-fsesl-akka/bin/bbb-fsesl-akka
     
     [program:red5]
     startsecs = 0
     autorestart = false
    -user=red5
    +user=tomcat7
    +group=root
     directory=/usr/share/red5
     command=/usr/share/red5/red5.sh
     
    @@ -50,42 +56,48 @@
     command=/usr/local/bigbluebutton/core/scripts/rap-archive-worker.rb
     directory=/usr/local/bigbluebutton/core/scripts
     user=tomcat7
    +group=root
     autorestart=true
     
     [program:rap-process-worker]
     command=/usr/local/bigbluebutton/core/scripts/rap-process-worker.rb
     directory=/usr/local/bigbluebutton/core/scripts
     user=tomcat7
    +group=root
     autorestart=true
     
     [program:rap-sanity-worker]
     command=/usr/local/bigbluebutton/core/scripts/rap-sanity-worker.rb
     directory=/usr/local/bigbluebutton/core/scripts
     user=tomcat7
    +group=root
     autorestart=true
     
     [program:rap-publish-worker]
     command=/usr/local/bigbluebutton/core/scripts/rap-publish-worker.rb 
     directory=/usr/local/bigbluebutton/core/scripts
     user=tomcat7
    +group=root
     autorestart=true
     
     [program:mongod]
     command=/usr/bin/mongod --quiet --config /etc/mongod.conf
     stdout_logfile=/var/log/supervisor/%(program_name)s.log
     stderr_logfile=/var/log/supervisor/%(program_name)s.log
    -user=mongodb
    +user=tomcat7
    +group=root
     autorestart=true
     
     [program:bbb-html5]
     command=/usr/share/meteor/bundle/systemd_start.sh
     directory=/usr/share/meteor/bundle
    -user=meteor
    -group=meteor
    +user=tomcat7
    +group=root
     autorestart=true
     
     [program:tomcat7]
     startsecs = 0
     autorestart = false
     user=tomcat7
    +group=root
     command=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre/bin/java -Djava.util.logging.config.file=/var/lib/tomcat7/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC -Xms256m -Xmx256m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/bigbluebutton/diagnostics -Djava.endorsed.dirs=/usr/share/tomcat7/endorsed -classpath /usr/share/tomcat7/bin/bootstrap.jar:/usr/share/tomcat7/bin/tomcat-juli.jar -Dcatalina.base=/var/lib/tomcat7 -Dcatalina.home=/usr/share/tomcat7 -Djava.io.tmpdir=/tmp/tomcat7-tomcat7-tmp org.apache.catalina.startup.Bootstrap start
