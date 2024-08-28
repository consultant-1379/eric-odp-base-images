#
# COPYRIGHT Ericsson 2024
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

ARG SELI_ARTIFACTORY_REPO_USER
ARG SELI_ARTIFACTORY_REPO_PASS
ARG CBOS_IMAGE_TAG=6.15.0-9
ARG CBOS_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os
ARG CBOS_IMAGE_NAME=sles

FROM ${CBOS_IMAGE_REPO}/${CBOS_IMAGE_NAME}:${CBOS_IMAGE_TAG} AS eric-odp-sles-base
ARG CBOS_IMAGE_TAG=6.15.0-9
ARG CBOS_REPO_URL=https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/${CBOS_IMAGE_TAG}

## use latest packages from SLES
COPY eric-odp-sles-base/image_content/repos/*.repo /etc/zypp/repos.d/

RUN zypper ar -C -G -f $CBOS_REPO_URL?ssl_verify=no \
    COMMON_BASE_OS_SLES_REPO \
    && zypper clean --all \
    && zypper ref && zypper --non-interactive update -y

##
RUN zypper install --no-recommends -y mozilla-nss glibc-extra curl

## this will include majority of groups and users in init container
## and will allow us to build images of eric-odp-main-container
## witthout OS rpms adding explictly entries in /etc/groups /etc/shadow
RUN zypper install --no-recommends -y system-user-* polkit

RUN zypper clean --all

ENV ERIC_ODP_HOME=/var/lib/eric-odp

RUN echo "ERIC_ODP_HOME=/var/lib/eric-odp" > /etc/environment

### TORF-605396
## update locale for programs that are locale sensitive to be able to function
## proper LANG has to be set in either eric-enm-sles-base or eric-enm-sles-eap7 image
RUN echo "LANG=$LANG" > /etc/locale.conf

#ARG USER_ID=40514
#RUN echo "$USER_ID:!::0:::::" >>/etc/shadow

#ARG USER_NAME="eric-odp-base-images"
#RUN echo "$USER_ID:x:$USER_ID:0:An Identity for $USER_NAME:/nonexistent:/bin/false" >>/etc/passwd

USER 0


ARG COMMIT
ARG BUILD_DATE
ARG APP_VERSION
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
LABEL \
    org.opencontainers.image.title=eric-odp-sles-base \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision="${RSTATE}" \
    com.ericsson.product-number="$IMAGE_PRODUCT_NUMBER"


FROM eric-odp-sles-base AS eric-odp-init

ARG BUILD_DATE=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified

LABEL \
com.ericsson.product-number="CXC 174 2010" \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ERICSSON ODP INIT IMAGE" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"


## to generate ssh keys and inject them into the main container
RUN zypper install --no-recommends -y openssh-common nss_synth && zypper clean --all

COPY eric-odp-init/image_content/scripts/*.sh /usr/local/bin/
COPY eric-odp-init/image_content/sshd/*.sh /usr/local/bin/
COPY eric-odp-init/image_content/sshd/sshd_config /usr/local/etc/


## required, as by default eric-odp-init during runtime will not have any details about existing user
## accessible through NSS subsystem, that's the reason we need integration with nss_synth
COPY eric-odp-init/image_content/etc/nsswitch.conf /etc/nsswitch.conf


FROM eric-odp-sles-base as eric-odp-main-container

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

#ARG SELI_ARTIFACTORY_REPO_USER
#ARG SELI_ARTIFACTORY_REPO_PASS
#ARG CBO_REPO=arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/
#ARG ARM_TOKEN
ARG STDOUT_VERSION
#ARG STDOUT_URL=https://arm.seli.gic.ericsson.se/artifactory/proj-adp-log-release/com/ericsson/bss/adp/log/stdout-redirect/

#RUN echo -e "$SELI_ARTIFACTORY_REPO_USER $SELI_ARTIFACTORY_REPO_PASS" && \
#curl -fsSL -o /tmp/stdout-redirect.tar -u ${SELI_ARTIFACTORY_REPO_USER}:${SELI_ARTIFACTORY_REPO_PASS} "${STDOUT_URL}/${STDOUT_VERSION}"/eric-log-libstdout-redirect-golang-cxa30176-"${STDOUT_VERSION}".x86_64.tar \
#    && tar -C / -xf /tmp/stdout-redirect.tar \
#    && rm -f /tmp/stdout-redirect.tar

COPY --chown=root:root --from=armdocker.rnd.ericsson.se/proj-adp-log-released/eric-log-shipper-sidecar:19.0.0-18 /opt/stdout-redirect/stdout-redirect /stdout-redirect

##
RUN chmod +x /stdout-redirect && \
zypper install --no-recommends -y openssh-server openssh-clients && zypper clean --all

RUN mkdir -p /ericsson/pod_setup/sshd/scripting

##prepare pam defaults
RUN rm -rf /etc/pam.d/common-* && pam-config --create

## copy template configuration for sshd
COPY eric-odp-main-container/image_content/sshd/scripting/* /ericsson/pod_setup/sshd/scripting/
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
