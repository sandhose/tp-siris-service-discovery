## Build the frontend assets
FROM --platform=${BUILDARCH} docker.io/library/node:16-slim AS frontend

WORKDIR /app

# Install the frontend dependencies
COPY package.json package-lock.json /app/
RUN npm ci

# Build the frontend assets
COPY tailwind.config.js /app/tailwind.config.js
COPY templates/ /app/templates/
RUN npm run build


## Common stage
FROM docker.io/library/python:3.10-slim AS app

ARG TARGETARCH

# Add tini
# Why? See http://blog.dscpl.com.au/2015/12/issues-with-running-as-pid-1-in-docker.html
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH} /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

WORKDIR /app

# Install the dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install -Ur requirements.txt

# Copy the rest of the code
COPY . /app/


## Worker stage
FROM app AS worker

ENV OTEL_SERVICE_NAME=worker
CMD ["opentelemetry-instrument", "celery", "-A", "tasks.app", "worker", "-E"]
USER 65534:65534


## Web stage
FROM app AS web

# Use waitress as WSGI server
RUN pip install waitress==2.1.1

# Get the built static assets from the frontend stage
COPY --from=frontend /app/static /app/static

ENV OTEL_SERVICE_NAME=web
CMD ["opentelemetry-instrument", "waitress-serve", "--call", "app:create_app"]
USER 65534:65534
EXPOSE 8080
