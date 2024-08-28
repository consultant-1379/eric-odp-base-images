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
org.label-schema.name="ERICSSON ODP INIT IMAGE" \
org.label-schema.build-date=$BUILD_DATE \
org.label-schema.vcs-ref=$GIT_COMMIT \
org.label-schema.vendor="Ericsson" \
org.label-schema.version=$IMAGE_BUILD_VERSION \
org.label-schema.schema-version="1.0.0-rc1"


## to generate ssh keys and inject them into the main container
RUN zypper install --no-recommends -y openssh-common nss_synth && zypper clean --all

COPY image_content/scripts/*.sh /usr/local/bin/
COPY image_content/sshd/*.sh /usr/local/bin/
COPY image_content/sshd/sshd_config /usr/local/etc/


## required, as by default eric-odp-init during runtime will not have any details about existing user
## accessible through NSS subsystem, that's the reason we need integration with nss_synth
COPY image_content/etc/nsswitch.conf /etc/nsswitch.conf
