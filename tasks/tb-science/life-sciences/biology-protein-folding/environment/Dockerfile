FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install OpenMM (lighter than GROMACS for this demo)
RUN pip3 install --no-cache-dir openmm openmm-tools pdbfixer

WORKDIR /workspace

# Install additional analysis tools
RUN pip3 install --no-cache-dir numpy scipy matplotlib