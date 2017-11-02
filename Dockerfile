FROM bigbluebutton/bigbluebutton:latest

MAINTAINER  Rich Lucente "rich.lucente@gmail.com"

LABEL io.k8s.description="Run BBB in OpenShift" \
      io.k8s.display-name="BigBlueButton" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="bigbluebutton"

# Give all directories to root group (not root user)
# https://docs.openshift.com/container-platform/3.6/creating_images/guidelines.html

RUN    chgrp -R 0 /bin /etc /home /media /mnt /opt /run /srv /tmp /usr /var \
    && chmod -R g=u /bin /etc /home /media /mnt /opt /run /srv /tmp /usr /var

USER 1000

EXPOSE 8080

