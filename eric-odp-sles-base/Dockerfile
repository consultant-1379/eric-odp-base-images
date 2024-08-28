ARG OS_BASE_IMAGE_NAME=sles
ARG OS_BASE_IMAGE_REPO=armdocker.rnd.ericsson.se/proj-ldc/common_base_os
ARG OS_BASE_IMAGE_TAG=6.13.0-10

FROM ${OS_BASE_IMAGE_REPO}/${OS_BASE_IMAGE_NAME}:${OS_BASE_IMAGE_TAG}

ARG BUILD_DATE=unspecified
ARG IMAGE_BUILD_VERSION=unspecified
ARG GIT_COMMIT=unspecified
ARG ISO_VERSION=unspecified
ARG RSTATE=unspecified


ARG SLES_BASE_OS_REPO=sles_base_os_repo
ARG CBO_REPO=arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/
ARG CBO_VERSION="6.13.0-10"

LABEL \
com.ericsson.product-number="CXC  " \
com.ericsson.product-revision=$RSTATE \
enm_iso_version=$ISO_VERSION \
org.label-schema.name="ERICSSON ODP BASE IMAGE" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"

## use repositories from CBOS
RUN zypper addrepo -C -G -f https://${CBO_REPO}${CBO_VERSION}?ssl_verify=no $SLES_BASE_OS_REPO 

## use latest packages from SLES
COPY image_content/repos/*.repo /etc/zypp/repos.d/
RUN zypper clean --all && zypper ref && zypper --non-interactive update -y

##
RUN zypper install --no-recommends -y mozilla-nss glibc-extra curl && zypper clean --all

ENV ERIC_ODP_HOME=/var/lib/eric-odp

RUN echo "ERIC_ODP_HOME=/var/lib/eric-odp" > /etc/environment

### TORF-605396
## update locale for programs that are locale sensitive to be able to function
## proper LANG has to be set in either eric-enm-sles-base or eric-enm-sles-eap7 image
RUN echo "LANG=$LANG" > /etc/locale.conf
