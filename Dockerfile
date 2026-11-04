FROM node:26.13.0-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94 AS build

USER node

ARG CI=true

ENV NODE_ENV=production

WORKDIR /home/node

COPY --chown=node:node ["package.json", "package-lock.json", "/home/node/"]

RUN npm ci --omit=dev

FROM node:26.13.0-alpine@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94

ARG USERNAME=nonroot
ARG USERHOME=/home/${USERNAME}

ENV NODE_ENV=production
ENV SERVICE_NAME="Node Micro Boilerplate"

RUN deluser --remove-home node && \
  addgroup \
    --gid 1000 \
    ${USERNAME} \
  && \
  adduser \
    --disabled-password \
    --home ${USERHOME} \
    --ingroup ${USERNAME} \
    --uid 1000 \
    ${USERNAME}

RUN apk update && apk add --no-cache tini

COPY --chown=${USERNAME}:${USERNAME} --from=build /home/node/node_modules ${USERHOME}/node_modules

COPY --chown=${USERNAME}:${USERNAME} . ${USERHOME}

WORKDIR ${USERHOME}

USER ${USERNAME}

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["node", "src/index.mjs"]
