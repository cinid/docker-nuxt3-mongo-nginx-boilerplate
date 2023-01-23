#-------------------------------------------------
# Multi-Stage: Build Production
#-------------------------------------------------
FROM mongo:5-focal AS production


### Set arguments and environment variables ##############

ARG app_env
ARG mongo_host
ARG mongo_port
ARG mongo_root_dir
ARG mongo_log_dir
ARG mongo_root_username
ARG mongo_root_password

ENV APP_ENV=$app_env
ENV MONGO_HOST=$mongo_host
ENV MONGO_PORT=$mongo_port
ENV MONGO_ROOT_DIR=$mongo_root_dir
ENV MONGO_LOG_DIR=$mongo_log_dir
ENV MONGO_ROOT_USERNAME=$mongo_root_username
ENV MONGO_ROOT_PASSWORD=$mongo_root_password


### Install and configure packages ###############

# Install packages
RUN apt-get update -y && apt-get install -y apt-utils gettext-base make cmake curl acl htop iputils-ping net-tools dnsutils nano vim git screen trash-cli build-essential \
                                            software-properties-common mlocate

# Install and configure locale
RUN apt-get update -y && apt-get install -y apt-transport-https gnupg libusb-1.0-0-dev libudev-dev locales locales-all \
 && locale-gen en_US.UTF-8 \
 # Source: https://serverfault.com/a/801162
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_TYPE=en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US.UTF-8' LC_ALL='en_US.UTF-8' LC_TYPE='en_US.UTF-8'


### Directory configuration ######################

# Create mongo root directory
RUN mkdir -p $mongo_root_dir

# Set additional permissions
RUN setfacl -dR -m u:mongodb:rwX,g:mongodb:rX,o::X $mongo_root_dir \
 && setfacl -R -m u:mongodb:rwX,g:mongodb:rX,o::X $mongo_root_dir

# Change ownership to user:group
# to prevent errno -13 "Your cache folder contains root-owned files, due to a bug in previous versions of npm which has since been addressed."
RUN chown -R mongodb:mongodb $mongo_root_dir

# Copy mongo directory and change ownership to user:group
COPY --chown=mongodb:mongodb ./mongo $mongo_root_dir


### Entrypoint configuration ######################

# Change user to root
USER root

# Copy MongoDB configuration and change permissions
COPY --chown=root:root ./.config/mongo/${APP_ENV}.mongod.conf /docker-entrypoint/mongod.conf
RUN chmod 644 /docker-entrypoint/mongod.conf

# Copy MongoDB init script and change permissions
COPY --chown=mongodb:mongodb ./.config/mongo/mongo-init.js /docker-entrypoint/mongo-init.js
RUN chmod 750 /docker-entrypoint/mongo-init.js

# Copy MongoDB mongo script and change permissions
COPY --chown=mongodb:mongodb ./.config/mongo/.mongoshrc.js /docker-entrypoint/.mongorc.js
RUN chmod 750 /docker-entrypoint/.mongorc.js

# Copy MongoDB mongosh script and change permissions
COPY --chown=mongodb:mongodb ./.config/mongo/.mongoshrc.js /docker-entrypoint/.mongoshrc.js
RUN chmod 750 /docker-entrypoint/.mongoshrc.js

# Copy Docker Entrypoint bash script and change permissions
COPY --chown=mongodb:mongodb ./.config/mongo/env-replace.sh /docker-entrypoint/env-replace.sh
RUN chmod 750 /docker-entrypoint/env-replace.sh

# Replace environment variables in several files write to output destination and delete input files
RUN /docker-entrypoint/env-replace.sh -di --input "/docker-entrypoint/mongod.conf" "/docker-entrypoint/mongo-init.js" "/docker-entrypoint/.mongorc.js" "/docker-entrypoint/.mongoshrc.js" --output "/etc/mongod.conf" "/docker-entrypoint-initdb.d/mongo-init.js" "${HOME}/.mongorc.js" "${HOME}/.mongoshrc.js"


### Final touches ################################

# Change user back to root
USER root

# Clean up
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

# Change user to mongodb
USER mongodb

# Start MongoDB Demon with custom configuration
CMD [ "mongod", "-f", "/etc/mongod.conf" ]


#-------------------------------------------------
# Multi-Stage: Build Development
#-------------------------------------------------
FROM production AS development
