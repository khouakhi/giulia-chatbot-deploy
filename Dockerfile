# Container image for Giulia (Chainlit) against MongoDB Atlas + Mistral.
# Upstream application code is cloned at build time so Giulia-Chatbot-v1 stays clean.
#
# Build:
#   docker build -t giulia-deploy .
#
# Build from a fork or pin:
#   docker build --build-arg GIULIA_REPO=https://github.com/you/Giulia-Chatbot-v1.git --build-arg GIULIA_REF=main -t giulia-deploy .

FROM python:3.11-slim-bookworm

ARG GIULIA_REPO=https://github.com/rendzina/Giulia-Chatbot-v1.git
ARG GIULIA_REF=main

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 --branch "${GIULIA_REF}" "${GIULIA_REPO}" .

RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir -p data/faiss SourceDocuments

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 8000

ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["/docker-entrypoint.sh"]
