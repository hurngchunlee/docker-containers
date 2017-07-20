FROM centos:7 

# application metadata
MAINTAINER Donders Institute
LABEL donders.ru.nl.app_name "docker-indico"
LABEL donders.ru.nl.app_maintainer "h.lee@donders.ru.nl"
LABEL donders.ru.nl.app_code_repository "https://github.com/hurngchunlee/docker-containers"

# install required system packages
RUN ( yum -y install sudo which gcc httpd mod_wsgi mod_ssl python python-setuptools python-devel python-ldap libxslt-devel libxml2-devel libxml2-python libffi-devel openldap-devel )

# install pip and supervisor from epel-release
RUN ( yum -y install epel-release )
RUN ( yum -y install python-pip )
RUN ( yum -y install supervisor )

# install indico
RUN ( pip install -U setuptools )
RUN ( easy_install indico )

# configure indico with initial setup 
COPY indico_initial_setup.txt /tmp/
RUN ( cat '/tmp/indico_initial_setup.txt' | indico_initial_setup )

# make python site-packages readable to all system users
# NOTE: this is an unusual workaround for the error:
#       IOError: [Errno 13] Permission denied: '/usr/lib/python2.7/site-packages/.../EGG-INFO/namespace_packages.txt'
RUN ( chmod -R a+r /usr/lib/python2.7/site-packages/ )

# copy apache configuration files
COPY httpd_indico.conf /etc/httpd/conf.d/indico.conf
COPY httpd_wsgi.conf /etc/httpd/conf.d/wsgi.conf
RUN ( mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.org )

# copy indico configuration files
COPY config/etc/*.conf /opt/indico/etc/
COPY config/ssl/indico.key /opt/indico/ssl/indico.key
COPY config/ssl/indico.crt /opt/indico/ssl/indico.crt

# copy supervisor configuration files
COPY supervisord.conf /opt/indico/supervisord.conf

# export entire indico volume
VOLUME [ "/opt/indico/archive", "/opt/indico/db", "/opt/indico/etc", "/opt/indico/ssl" ]
EXPOSE 80 443

CMD [ "/usr/bin/supervisord", "-c", "/opt/indico/supervisord.conf" ]
#CMD [ "/opt/stager/start_stager.sh" ]
