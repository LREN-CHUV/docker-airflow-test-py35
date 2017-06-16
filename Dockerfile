FROM python:3.5-alpine
MAINTAINER Ludovic Claude <ludovic.claude@chuv.ch>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

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
      apache-airflow==1.8.1 \
      pydicom>=0.9.9 \
      SQLAlchemy>=1.1.6 \
      python-magic>=0.4.12 \
      nibabel>=2.1.0 \
      psycopg2>=2.7.1 \
      nose==1.3.7

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
