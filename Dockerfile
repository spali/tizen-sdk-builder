ARG TIZEN_HOME_DIR=/tizen
ARG TIZEN_SDK_VERSION=4.5.1
ARG TIZEN_SDK_PATH=${TIZEN_HOME_DIR:?}/tizen-studio
ARG TIZEN_SDK_INSTALLER_FILE_NAME=web-cli_Tizen_Studio_${TIZEN_SDK_VERSION:?}_ubuntu-64.bin
ARG TIZEN_SDK_CLI_INSTALLER_URL=http://download.tizen.org/sdk/Installer/tizen-studio_${TIZEN_SDK_VERSION:?}/${TIZEN_SDK_INSTALLER_FILE_NAME:?}
ARG TIZEN_SDK_CLI_INSTALLER_PATH=${TIZEN_HOME_DIR:?}/${TIZEN_SDK_INSTALLER_FILE_NAME:?}

FROM ubuntu:18.04

ARG TIZEN_HOME_DIR
ARG TIZEN_SDK_PATH
ARG TIZEN_SDK_DATA_PATH
ARG TIZEN_SDK_CLI_INSTALLER_URL
ARG TIZEN_SDK_CLI_INSTALLER_PATH

RUN apt-get update \
  && apt-get install --yes \
     curl \
     pciutils \
     zip \
  && apt-get clean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/apt/lists/*

# tizen cli installer wants non-root user
RUN useradd -m -d ${TIZEN_HOME_DIR:?} tizen
USER tizen

COPY --chown=tizen /vendor /tizen/

RUN export installer=$(find /tizen -type f -name "web-cli_*ubuntu-*.bin") \
  && ([ -n "$installer" ] && (mv -v $installer ${TIZEN_SDK_CLI_INSTALLER_PATH} || true)) || curl -s ${TIZEN_SDK_CLI_INSTALLER_URL} > ${TIZEN_SDK_CLI_INSTALLER_PATH}

RUN mkdir -p ${TIZEN_SDK_PATH:?} \
  && chmod +x ${TIZEN_SDK_CLI_INSTALLER_PATH:?} \
  && ${TIZEN_SDK_CLI_INSTALLER_PATH:?} --no-java-check --accept-license ${TIZEN_SDK_PATH:?} \
  && rm ${TIZEN_SDK_CLI_INSTALLER_PATH:?} \
  && ${TIZEN_SDK_PATH:?}/tools/certificate-generator/patches/public/patch.sh ${TIZEN_SDK_PATH:?} \
  && rm -rf ${TIZEN_HOME_DIR:?}/.package-manager ${TIZEN_SDK_PATH:?}/license ${TIZEN_SDK_PATH:?}/package-manager

ENV PATH="${TIZEN_SDK_PATH:?}/tools:${TIZEN_SDK_PATH:?}/tools/ide/bin:${PATH}"

