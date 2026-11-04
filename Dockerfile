# The forms server image (form.io with the formsflow extensions).
# Node 24 LTS, pinned by digest; dependencies installed from the lockfile. No compilers or git:
# every dependency is plain JavaScript and comes from the npm registry.
FROM node:24-alpine@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53

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
