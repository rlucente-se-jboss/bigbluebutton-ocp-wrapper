FROM bigbluebutton/bigbluebutton:latest

MAINTAINER  Rich Lucente "rich.lucente@gmail.com"

LABEL io.k8s.description="Run BBB in OpenShift" \
      io.k8s.display-name="BigBlueButton" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="bigbluebutton"

ENV dirlist /root /etc /home /media /mnt /opt /srv /tmp /usr /var \ 
            /run/lock /run/mount /run/systemd /run/secrets /run/secrets/rhsm  \
            /run/secrets/rhsm/ca /run/secrets/rhsm/pluginconf.d \
            /run/secrets/rhsm/facts /run/secrets/etc-pki-entitlement

# DO NOT REQUIRE root TO RUN
ADD    tomcat7 /etc/init.d/tomcat7

# Give all directories to root group (not root user)
# https://docs.openshift.com/container-platform/3.6/creating_images/guidelines.html
RUN    chmod a+x /etc/init.d/tomcat7 \
    && chgrp -R 0 $dirlist \
    && chmod -R g=u $dirlist

USER 1000

EXPOSE 8080

