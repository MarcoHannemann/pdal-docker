FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    ca-certificates \
    cmake \
    git \
    libgdal-dev \
    ninja-build \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://code-server.dev/install.sh | sh

EXPOSE 8080

WORKDIR /workspace

RUN git clone -b stable --depth 1 https://github.com/PDAL/PDAL.git

WORKDIR /workspace/PDAL

RUN mkdir build && \
    cd build && \
    cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=lib .. \
    ninja && \
    ninja install

RUN pip install --upgrade pip

### This block is testing if (1) python-pdal can be installed and finds the PDAL bindings
WORKDIR /workspace
RUN python -m venv venv/ && \
    /bin/bash -c "source venv/bin/activate && pip install PDAL"

COPY test-pdal-python.sh /workspace/test-pdal-python.sh
RUN chmod +x /workspace/test-pdal-python.sh
RUN ./test-pdal-python.sh && rm /workspace/test-pdal-python.sh
###

RUN rm -rf /workspace/PDAL

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "/workspace"]
