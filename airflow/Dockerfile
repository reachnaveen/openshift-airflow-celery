FROM python:3.6-slim

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_GPL_UNIDECODE yes

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8


# Image metadata
ENV NAME="majordomusio/openshift-airflow" \
    SUMMARY="Apache Airflow on OpenShift"	\
    DESCRIPTION="Apache Airflow on OpenShift" \
    MAINTAINER="majordomusio <hello@ratchet.cc>" \
    VENDOR="majordomusio" \
    TAGS="airflow" \
    VERSION="1.10" \
    RELEASE="1.10"

LABEL name="$NAME" \
      maintainer="$MAINTAINER" \
      vendor="$VENDOR" \
      version="$VERSION" \
      release="$RELEASE" \
      summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="DESCRIPTION" \
      io.k8s.display-name="$NAME" \
      io.openshift.tags="$TAGS"

#
# Prepare the image
#

ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    HOME="/usr/local/app" \
    USER_ID=1001 \
    USER_NAME=default

ENV PATH=$HOME/.local/bin/:$PATH

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,kubernetes,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip install 'redis>=2.10.5,<3' \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base
    

ENV ARCH=x86_64 \
    PYTHON_ALIAS="python3" \
    PIP_ALIAS="pip3" \
    PIP_ARGS="" \
    PYTHON_VERSION="3.6" \
    PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING="UTF-8" \
    PIP_NO_CACHE_DIR="off"

ENV PATH=$HOME/.local/bin/:$PATH

COPY ./include/ /



# Add the default user
RUN useradd -u ${USER_ID} -r -g 0 -d ${HOME} -s /sbin/nologin \
    -c "Default User" ${USER_NAME} && \
    chown -R ${USER_ID}:0 ${HOME}


# see https://github.com/jupyter/docker-stacks/issues/552
RUN chmod 766 /etc/passwd && chmod 766 /etc/group

ENV PYTHONPATH=${PYTHONPATH:+${PYTHONPATH}:}${AIRFLOW_HOME}
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

# Install the OpenShift CLI
ENV OPENSHIFT_CLI_BINARY="openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit" \
    OPENSHIFT_VERSION="v3.11.0"

RUN curl -L -0 "https://github.com/openshift/origin/releases/download/${OPENSHIFT_VERSION}/${OPENSHIFT_CLI_BINARY}.tar.gz" | tar -zx -C /tmp && \
    mv /tmp/${OPENSHIFT_CLI_BINARY}/oc /usr/bin && \
    mv /tmp/${OPENSHIFT_CLI_BINARY}/kubectl /usr/bin
    
RUN chown -R ${USER_ID}:0 ${AIRFLOW_HOME} && \
    fix-permissions ${AIRFLOW_HOME} -P

# Create directories so we can own them when we mount volumes
RUN mkdir -p ${AIRFLOW_HOME}/logs && mkdir -p ${AIRFLOW_HOME}/dags

#
# Finalize the image
#

RUN chown -R ${USER_ID}:0 ${AIRFLOW_HOME} && \
	fix-permissions ${AIRFLOW_HOME} -P


# Switch to AIRFLOW_HOME
WORKDIR ${AIRFLOW_HOME}
USER ${USER_ID}

# Expose all airflow ports
EXPOSE 8080 5555 8793

# Run airflow with minimal init
CMD ["start-airflow"]
