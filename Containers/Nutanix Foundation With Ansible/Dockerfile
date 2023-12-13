# Docker Container Build Version
ARG VARIANT="none"
FROM mcr.microsoft.com/vscode/devcontainers/python:${VARIANT}

# Options
ARG USERNAME="vscode"
ARG ANSIBLE_VERSION="latest"
ARG PYWINRM_VERSION="latest"

# Install Ansible
RUN if [ "${ANSIBLE_VERSION}" = "latest" ]; then \
        pip3 --disable-pip-version-check --no-cache-dir install ansible ; \
    else \
        pip3 --disable-pip-version-check --no-cache-dir install ansible==${ANSIBLE_VERSION} ; \
    fi

# Install pywinrm
RUN if [ "${PYWINRM_VERSION}" = "latest" ]; then \
        pip3 --disable-pip-version-check --no-cache-dir install pywinrm ; \
    else \
        pip3 --disable-pip-version-check --no-cache-dir install pywinrm==${PYWINRM_VERSION} ; \
    fi

# Install Additional Packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends xorriso udftools growisofs genisoimage
