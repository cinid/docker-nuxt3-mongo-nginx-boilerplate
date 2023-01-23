#-------------------------------------------------
# Multi-Stage: Build Production
#-------------------------------------------------
FROM node:18.13-buster AS production


### Set arguments and environment variables ##############

ARG node_root_dir
ARG nuxt_root_dir
ARG npm_version
ARG pnpm_version

ENV PYTHONUNBUFFERED=1
# Source: https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md#global-npm-dependencies
ENV NPM_CONFIG_PREFIX="$node_root_dir/.npm-global"
# Source: https://github.com/nodejs/docker-node/issues/601
ENV PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"


### Install and configure packages ###############

# Install packages
RUN apt-get update -y && apt-get install -y apt-utils gettext-base make cmake curl acl htop iputils-ping net-tools dnsutils nano vim git screen trash-cli build-essential \
                                            software-properties-common mlocate \
                                            # Source: https://docs.docker.com/engine/install/debian/#install-using-the-repository
                                            ca-certificates curl gnupg lsb-release

# Install and configure locale
RUN apt-get update -y && apt-get install -y apt-transport-https gnupg libusb-1.0-0-dev libudev-dev locales locales-all \
 && locale-gen en_US.UTF-8 \
 # Source: https://serverfault.com/a/801162
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_TYPE=en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8' LC_TYPE='en_US.UTF-8'


### Directory configuration ######################

# Create npm global directory before install
RUN mkdir -p ${NPM_CONFIG_PREFIX}

# Set additional permissions
RUN setfacl -dR -m u:node:rwX,g:node:rX,o::X $node_root_dir ${NPM_CONFIG_PREFIX} \
 && setfacl -R -m u:node:rwX,g:node:rX,o::X $node_root_dir ${NPM_CONFIG_PREFIX}

# Change ownership to user:group
# to prevent errno -13 "Your cache folder contains root-owned files, due to a bug in previous versions of npm which has since been addressed."
RUN chown -R node:node $node_root_dir

# Copy nuxt directory and change ownership to user:group
COPY --chown=node:node ./nuxt $nuxt_root_dir

# Set working directory
WORKDIR $node_root_dir


### Install and configure npm packages ###########

# Change user to node
USER node

# Update npm and init
RUN npm install -g npm@$npm_version \
 && npm init -y \
# Global packages
 && npm install -g npm-check-updates pnpm@$pnpm_version pm2 \
 && npm install -g --save dotenv node-gyp @mapbox/node-pre-gyp \
# Local packages
 && npm install http-server
RUN npm install


### Final touches ################################

# Change user back to root
USER root

# Clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*


#-------------------------------------------------
# Multi-Stage: Build Development
#-------------------------------------------------
FROM production AS development


### Directory configuration ######################

# Set working directory
WORKDIR $node_root_dir


### Install and configure npm packages ###########

# Change user to node
USER node

# Local packages
RUN npm install -D nodemon


### Final touches ################################

# Change user back to root
USER root

# Clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

# Set working directory
WORKDIR $node_root_dir

USER node
