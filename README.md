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
