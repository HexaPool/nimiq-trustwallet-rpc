FROM node:10-stretch

# Build from master branch by default.
# One can override this using --build-arg when building the docker
# image from this file.
ARG BRANCH=master

# Install dependencies
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y build-essential git-core

# We're going to execute nimiq in the context of its own user, what else?
ENV USER=nimiq
RUN useradd -m ${USER}

# Create a working directory for the nimiq process
ENV DATA_PATH=/nimiq
RUN mkdir ${DATA_PATH} && chown ${USER}:root ${DATA_PATH}
WORKDIR ${DATA_PATH}

# Build environment as non-root user
USER ${USER}

# Clone
RUN git clone --branch ${BRANCH} https://github.com/nimiq/core-js.git core

# Build
RUN cd core && yarn

# Remove build tools
USER root
RUN apt-get remove -y build-essential

# Execute client as non-root user
USER ${USER}

#Workaround to fix light consensus
#COPY index.js ./core/clients/nodejs

#Workaround to fix integer bug
#COPY JsonRpcServer.js ./core/clients/nodejs/modules

# Just execute the nimiq process. One can customize the created container easily
# to one's needs by (at least) the following options:
# - supply your own arguments to the entrypoint while creating the container, e.g.
#    docker run nimiq/nodejs-client --miner
# - just bind mount your own nimiq.conf to the container at /etc/nimiq/nimiq.conf
#   then you can just create the container like (assuming the config is in the
#   current working directory)
#     docker run nimiq/nodejs-client -v $(pwd)/nimiq.conf:/etc/nimiq/nimiq.conf --config=/etc/nimiq.conf
# (- of course, you can combine and modify these options suitable to your needs)
ENTRYPOINT [ "./core/clients/nodejs/nimiq" ]
