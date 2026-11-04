# The forms server image (form.io with the formsflow extensions).
# Node 24 LTS; dependencies installed from the lockfile. No compilers or git:
# every dependency is plain JavaScript and comes from the npm registry.
FROM node:24-alpine

LABEL Name="formsflow"

# A build with --no-cache can set CACHE_ID to start from an empty npm cache.
ARG CACHE_ID=shared

WORKDIR /app

# The server writes into /app at runtime, also when started as an arbitrary user (OpenShift).
RUN chmod 777 /app

ENV PATH=/app/node_modules/.bin:$PATH

# Lockfile first, so a source change doesn't repeat the downloads.
COPY package.json package-lock.json /app/
RUN --mount=type=cache,id=ff-npm-$CACHE_ID,target=/root/.npm \
    npm config set fetch-retries 6 && npm config set fetch-retry-maxtimeout 120000 && \
    npm ci --omit=dev --no-audit --no-fund --loglevel=error

# Set this to inspect more from the application. Examples:
#   DEBUG=formio:db (see index.js for more)
#   DEBUG=formio:*
ENV DEBUG=""

COPY . /app/

# Node 21+ compatibility shim (see node-compat.js), for the server and the workers it starts.
ENV NODE_OPTIONS="--require /app/node-compat.js"

ENTRYPOINT [ "node", "main" ]
