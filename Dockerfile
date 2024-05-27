# syntax=docker/dockerfile:1.2

# Stage 1: Base Image with Python
# Use Python 3.9 on Alpine Linux as the base image for the build stage
FROM python:3.9-alpine AS base

# Set working directory inside the container
WORKDIR /app

# Install git for cloning the repository
RUN apk add --no-cache git

# Clone the repository containing the application code
RUN --mount=type=cache,target=/root/.npm git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Copy the requirements file and install dependencies with cache optimization
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt

# Stage 2: Final Image with Application Code
# Use Python 3.9 on Alpine Linux as the base image for the final stage
FROM python:3.9-alpine AS final

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
