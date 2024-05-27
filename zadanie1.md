Zrzut ekranowy jest podany w result.png

Kod i polecenia(etap3) dla obowiązkowej części zadania1:

# Stage 1: Base Image with Python
FROM python:3.9-alpine AS base

# Set working directory
WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Stage 2: Final Image with Application Code
FROM python:3.9-alpine

# Set working directory
WORKDIR /app

# Copy the dependencies from the base stage
COPY --from=base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Copy the rest of the source code
COPY server.py .

# Expose the port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Run the server
CMD ["python", "server.py"]

# Polecenia dla 3 etapu
1. docker build -t docker_zadanie1:latest -f Dockerfile .

2. docker run -d -p 3000:3000 --name docker_zadanie1_container docker_zadanie1:latest

3. docker logs docker_zadanie1_container

4. docker history docker_zadanie1:latest


