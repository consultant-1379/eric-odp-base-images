ARG ERIC_ODP_BASE_IMAGE_NAME=eric-odp-sles-base
ARG ERIC_ODP_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj_oss_releases/enm
ARG ERIC_ODP_BASE_IMAGE_TAG=latest
ARG IMAGE_BUILD_VERSION

FROM ${ERIC_ODP_BASE_IMAGE_REPO}/${ERIC_ODP_BASE_IMAGE_NAME}:${IMAGE_BUILD_VERSION}

ARG BUILD_DATE=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified

LABEL \
com.ericsson.product-number="CXC 174 2010" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ERICSSON ODP MAIN CONTAINER IMAGE" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

ARG CBO_REPO=arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/
ARG OS_BASE_IMAGE_TAG
ARG ARM_TOKEN
ARG STDOUT_VERSION
ARG STDOUT_URL=https://arm.seli.gic.ericsson.se/artifactory/proj-adp-log-release/com/ericsson/bss/adp/log/stdout-redirect/

RUN curl -fsSL -o /tmp/stdout-redirect.tar -H "X-JFrog-Art-Api:${ARM_TOKEN}" "${STDOUT_URL}/${STDOUT_VERSION}"/eric-log-libstdout-redirect-golang-cxa30176-"${STDOUT_VERSION}".x86_64.tar \
    && tar -C / -xf /tmp/stdout-redirect.tar \
    && rm -f /tmp/stdout-redirect.tar

##
RUN zypper install --no-recommends -y openssh-server openssh-clients && zypper clean --all

RUN mkdir -p /ericsson/pod_setup/sshd/scripting

##prepare pam defaults
RUN rm -rf /etc/pam.d/common-* && pam-config --create

## copy template configuration for sshd
COPY image_content/sshd/scripting/* /ericsson/pod_setup/sshd/scripting/
RUN chmod 755 /ericsson/pod_setup/sshd/scripting/*

## to run sshd as user
## generate in ephemeral storage ssh keys, or let them be published by Kubernetes
## have configuration file of same format as /etc/ssh/sshd_config be accessible by user
## start sshd in background

RUN mkdir -p $ERIC_ODP_HOME && \
    cp /etc/passwd /etc/group /etc/shadow $ERIC_ODP_HOME && \
    rm -rf /etc/passwd /etc/group /etc/shadow && \
    ln -s $ERIC_ODP_HOME/passwd /etc/passwd && \
    ln -s $ERIC_ODP_HOME/group /etc/group && \
    ln -s $ERIC_ODP_HOME/shadow /etc/shadow && \
    ls -al /etc/passwd; ls -al /etc/group; ls -al /etc/shadow
