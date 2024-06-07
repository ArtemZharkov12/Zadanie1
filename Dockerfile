# syntax=docker/dockerfile:1.2

# Stage 1: Base Image with Python
# Use Python 3.9 on Debian Slim as the base image for the build stage
FROM python:3.9-slim AS base

# Set working directory inside the container
WORKDIR /app

# Install git for cloning the repository
RUN apt-get update && apt-get install -y git --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Clone the repository containing the application code
RUN git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Copy the requirements file and install dependencies with cache optimization
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final Image with Application Code
# Use Python 3.9 on Debian Slim as the base image for the final stage
FROM python:3.9-slim AS final

# Set working directory inside the container
WORKDIR /app

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
CMD ["python", "server.py"]
