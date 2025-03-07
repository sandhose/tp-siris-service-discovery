## Common stage
FROM ghcr.io/astral-sh/uv:python3.13-bookworm AS app

ARG TARGETARCH

# Add tini
# Why? See http://blog.dscpl.com.au/2015/12/issues-with-running-as-pid-1-in-docker.html
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH} /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

WORKDIR /app

# Install app
COPY . /app/
RUN uv sync

## Worker stage
FROM app AS worker

ENV OTEL_SERVICE_NAME=worker
CMD uv run opentelemetry-instrument celery -A tasks.app worker -E

## Web stage
FROM app AS web

# Use waitress as WSGI server
RUN uv pip install waitress==3.0.2

ENV OTEL_SERVICE_NAME=web
CMD uv run opentelemetry-instrument waitress-serve --call app:create_app
EXPOSE 8080
