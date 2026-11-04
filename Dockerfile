# The forms server image (form.io with the formsflow extensions).
# Node 24 LTS; dependencies installed from the lockfile. No compilers or git:
# every dependency is plain JavaScript and comes from the npm registry.
FROM node:24-alpine

LABEL Name="formsflow"

WORKDIR /app

# The server writes into /app at runtime, also when started as an arbitrary user (OpenShift).
RUN chmod 777 /app

ENV PATH=/app/node_modules/.bin:$PATH

# Lockfile first, so a source change doesn't repeat the downloads.
COPY package.json package-lock.json /app/
RUN npm ci --omit=dev --no-audit --no-fund --loglevel=error

# Set this to inspect more from the application. Examples:
#   DEBUG=formio:db (see index.js for more)
#   DEBUG=formio:*
ENV DEBUG=""

COPY . /app/

# Node 21+ compatibility shim (see node-compat.js), for the server and the workers it starts.
ENV NODE_OPTIONS="--require /app/node-compat.js"

ENTRYPOINT [ "node", "main" ]
