FROM node:22.18.0-alpine@sha256:1b2479dd35a99687d6638f5976fd235e26c5b37e8122f786fcd5fe231d63de5b AS build

USER node

ARG CI=true

ENV NODE_ENV=production

WORKDIR /home/node

COPY --chown=node:node ["package.json", "package-lock.json", "/home/node/"]

RUN npm ci --omit=dev

FROM node:22.18.0-alpine@sha256:1b2479dd35a99687d6638f5976fd235e26c5b37e8122f786fcd5fe231d63de5b

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
