FROM python:3.6-alpine3.8

ARG NGINX_VERSION=1.14
ENV CPUS=''
ENV APP_ROOT='/app'
# copy all the files in build context
COPY . /tmp/build_context

RUN addgroup -S appserver \
    # create a group & a system user with no password and no login
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G appserver appserver \
    # install nginx and gunicorn from alpine repo
	&& apk add --update --no-cache nginx>=${NGINX_VERSION} \
    # make app root dir
    && mkdir -p $APP_ROOT \
    # create pid dir for nginx and gunicorn
    && mkdir -p /run/pid \
    # create dir for socket file
    && mkdir -p /run/gunicorn \
    # create log files dir for nginx and gunicorn
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/log/gunicorn \
    # create nginx client temp dir
    && mkdir -p /tmp/nginx/client_body \
    # copy app code
    && mv /tmp/build_context/app/* $APP_ROOT \
    # touch files used by nginx and gunicorn
    # && touch /run/pid/nginx.pid \
    # && touch /run/pid/gunicorn.pid \
    && touch /var/log/nginx/access.log \
	&& touch /var/log/nginx/error.log \
    && touch /var/log/gunicorn/error.log \
    # change ownership and file access
    && chown -R appserver $APP_ROOT \
    && chown -R appserver /run/pid/ \
    && chown -R appserver /run/gunicorn/ \
    && chown -R appserver /var/log/nginx \
    && chown -R appserver /var/log/gunicorn \
    && chmod +x $APP_ROOT/start \
    && chmod +x $APP_ROOT/entrypoint \
    # && chmod -R u=xrw /run/pid \
    # && chmod -R u=xrw /run/gunicorn \
    && chmod -R u=xrw /var/log/nginx \
    && chmod -R u=xrw /var/log/gunicorn \
    # copy nginx configs from build context
    && mv /tmp/build_context/conf/nginx/nginx.conf /etc/nginx/ \
    && mv /tmp/build_context/conf/nginx/appserver.conf /etc/nginx/conf.d/ \
    # copy the guicon config to app root to load it as python module
    && mv /tmp/build_context/conf/gunicorn/gunicorn.conf.py $APP_ROOT/ \
    # install app depencencies
    && pip install -r /tmp/build_context/requirements.txt \
    # remove default conf
    && rm -rf /etc/nginx/conf.d/default.conf \
    # clean up copied artifacts
    && rm -rf /tmp/build_context

WORKDIR $APP_ROOT

EXPOSE 8080

ENTRYPOINT [ "./entrypoint" ]

CMD [ "gunicorn", "app.wsgi" ]
