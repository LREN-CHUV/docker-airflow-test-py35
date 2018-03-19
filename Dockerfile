FROM python:3.5-alpine
MAINTAINER Ludovic Claude <ludovic.claude@chuv.ch>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

### Install Docker - code copied from https://github.com/docker-library/docker/blob/168a6d227d021c6d38c3986b7c668702ec172fa7/17.06/Dockerfile

RUN apk add --no-cache \
		ca-certificates

ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 17.06.2-ce
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN set -ex; \
# why we use "curl" instead of "wget":
# + wget -O docker.tgz https://download.docker.com/linux/static/stable/x86_64/docker-17.03.1-ce.tgz
# Connecting to download.docker.com (54.230.87.253:443)
# wget: error getting response: Connection reset by peer
	apk add --no-cache --virtual .fetch-deps \
		curl \
		tar \
	; \
# this "case" statement is generated via "update.sh"
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64) dockerArch='x86_64' ;; \
		s390x) dockerArch='s390x' ;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;\
	esac; \
	if ! curl -fL -o docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
		exit 1; \
	fi; \
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	apk del .fetch-deps; \
	dockerd -v; \
	docker -v

### Install docker-compose - code copied from https://github.com/tmaier/docker-compose/blob/master/17.06/Dockerfile

RUN apk add --no-cache py-pip
RUN pip install docker-compose

### Code copied from docker-compose-for-ci/Dockerfile

RUN apk add --update --no-cache bash build-base git py-pip python python-dev curl \
    && pip2.7 install pre-commit==1.3.0 \
    && sed -i -e 's|/usr/bin/python|/usr/bin/python2.7|' /usr/bin/pre-commit \
    && curl -sSL https://raw.githubusercontent.com/harbur/captain/v1.1.0/install.sh | bash \
    && rm -rf /var/cache/apk/* /tmp/*

### Install Airflow and other dependencies

RUN apk add --update --no-cache \
      build-base \
      postgresql-dev \
      gcc \
      bash \
      libxslt \
      libxslt-dev \
      libxml2 \
      libxml2-dev  \
      linux-headers \
      libmagic

RUN pip -v install \
      pydicom>=0.9.9 \
      sqlalchemy==1.2.5 \
      python-magic>=0.4.12 \
      nibabel>=2.1.0 \
      psycopg2-binary==2.7.4 \
    && pip -v install apache-airflow==1.9.0 \
    && pip -v install nose==1.3.7

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="hbpmip/airflow-test-py35" \
      org.label-schema.description="Airflow with nosetests running on Python 3.5" \
      org.label-schema.url="https://github.com/LREN-CHUV/docker-airflow-test-py35" \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/LREN-CHUV/docker-airflow-test-py35" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version="$VERSION" \
      org.label-schema.vendor="LREN CHUV" \
      org.label-schema.license="Apache2.0" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.schema-version="1.0"
