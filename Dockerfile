FROM node:18.13.0-alpine@sha256:fda98168118e5a8f4269efca4101ee51dd5c75c0fe56d8eb6fad80455c2f5827 AS build

USER node

ARG CI=true

ENV NODE_ENV=production

WORKDIR /home/node

COPY --chown=node:node ["package.json", "package-lock.json", "/home/node/"]

RUN npm ci --omit=dev

FROM node:18.13.0-alpine@sha256:fda98168118e5a8f4269efca4101ee51dd5c75c0fe56d8eb6fad80455c2f5827

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
