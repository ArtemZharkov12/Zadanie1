# syntax=docker/dockerfile:1.2

# Stage 1: Base Image with Node.js
FROM node:14 AS base

# Set working directory inside the container
WORKDIR /app

# Install git for cloning the repository
RUN apt-get update && apt-get install -y git

# Clone the repository containing the application code
RUN git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Copy the package.json and package-lock.json (if available)
COPY package.json ./
COPY package-lock.json ./

# Install dependencies with cache optimization
RUN npm install

# Build the application
RUN npm run build

# Stage 2: Final Image with Node.js and Application Code
FROM node:14 AS final

# Set working directory inside the container
WORKDIR /app

# Copy the built application from the previous stage
COPY --from=base /app .

# Expose the port on which the server will run
EXPOSE 3000

# Healthcheck to ensure the server is running correctly
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Run the server using Node.js
CMD ["node", "server.js"]
