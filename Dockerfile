FROM node:16.15.0-alpine@sha256:1a9a71ea86aad332aa7740316d4111ee1bd4e890df47d3b5eff3e5bded3b3d10 AS build

USER node

ARG CI=true

ENV NODE_ENV=production

WORKDIR /home/node

COPY --chown=node:node ["package.json", "package-lock.json", "/home/node/"]

RUN npm ci --only=production

FROM node:16.15.0-alpine@sha256:1a9a71ea86aad332aa7740316d4111ee1bd4e890df47d3b5eff3e5bded3b3d10

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

CMD ["node", "--experimental-specifier-resolution=node", "src/index"]
