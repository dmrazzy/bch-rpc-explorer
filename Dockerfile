FROM node:20.19.2-bookworm-slim as builder
WORKDIR /workspace
RUN apt-get update -q && \
    apt-get install -qy build-essential git python
ADD package*.json /workspace
RUN npm install && \
    apt-get remove -qy build-essential git python &&\
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove -y && \
    apt-get clean

FROM node:20.19.2-bookworm-slim
RUN apt-get update -q && \
    apt-get install -qy libjemalloc2 && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove -y && \
    apt-get clean
WORKDIR /workspace
COPY --from=builder /workspace .
CMD node-gyp rebuild
ENV NODE_OPTIONS=--max_old_space_size=4096
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
ADD . /workspace
CMD npm start
EXPOSE 3002
