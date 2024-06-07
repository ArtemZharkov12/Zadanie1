# syntax=docker/dockerfile:1.2

# Stage 1: Base Image with Python
# Use Debian Slim as the base image for the build stage
FROM debian:bullseye-slim AS base

# Set working directory inside the container
WORKDIR /app

# Replace the default Debian mirror with a different one (for example, a mirror from your region)
RUN sed -i 's|http://deb.debian.org/debian|http://ftp.us.debian.org/debian|g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    git \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    python3-pip \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Clone the repository containing the application code
RUN git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Copy the requirements file and install dependencies with cache optimization
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Stage 2: Final Image with Application Code
# Use Debian Slim as the base image for the final stage
FROM debian:bullseye-slim AS final

# Set working directory inside the container
WORKDIR /app

# Install minimal dependencies
RUN apt-get update && apt-get install -y \
    python3.9 \
    python3.9-venv \
    --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Copy the dependencies installed in the build stage to the final image
COPY --from=base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Copy the application code from the build stage to the final image
COPY server.py .

# Expose the port on which the server will run
EXPOSE 3000

# Add a healthcheck to ensure the server is running correctly
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Run the server using the Python interpreter
CMD ["python3", "server.py"]
