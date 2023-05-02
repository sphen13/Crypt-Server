FROM python:3.10.8-alpine3.16

LABEL maintainer="graham@grahamgilbert.com"

ENV APP_DIR /home/docker/crypt
ENV DEBUG false
ENV LANG en
ENV TZ Etc/UTC
ENV LC_ALL en_US.UTF-8



RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    git \
    openssl-dev \
    build-base \
    libffi-dev \
    libc-dev \
    musl-dev \
    linux-headers \
    pcre-dev \
    postgresql-dev \
    mariadb-dev \
    xmlsec-dev \
    tzdata \
    postgresql-libs \
    libpq

COPY setup/requirements.txt /tmp/requirements.txt

RUN set -ex \
    && LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "pip install --no-cache-dir -r /tmp/requirements.txt" \
    && rm /tmp/requirements.txt

COPY / $APP_DIR
COPY docker/settings.py $APP_DIR/fvserver/
COPY docker/settings_import.py $APP_DIR/fvserver/
COPY docker/gunicorn_config.py $APP_DIR/
COPY docker/django/management/ $APP_DIR/server/management/
COPY docker/run.sh /run.sh

RUN chmod +x /run.sh \
    && mkdir -p /home/app \
    && ln -s ${APP_DIR} /home/app/crypt

WORKDIR ${APP_DIR}
# don't use this key anywhere else, this is just for collectstatic to run
RUN export FIELD_ENCRYPTION_KEY="jKAv1Sde8m6jCYFnmps0iXkUfAilweNVjbvoebBrDwg="; python manage.py collectstatic --noinput; export FIELD_ENCRYPTION_KEY=""

EXPOSE 8000

VOLUME $APP_DIR/keyset

CMD ["/run.sh"]
