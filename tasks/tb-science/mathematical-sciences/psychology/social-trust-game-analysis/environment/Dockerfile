FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    numpy \
    scipy \
    pandas \
    emcee \
    arviz \
    pymc \
    tqdm \
    msgpack \
    pyyaml \
    json

WORKDIR /workspace

COPY --chown=agent:agent instructions.md /app/instructions.md
COPY --chown=agent:agent trust_game_data.csv /app/trust_game_data.csv
COPY --chown=agent:agent true_params.json /app/true_params.json

RUN mkdir -p /workspace/results && chown -R agent:agent /workspace

USER agent