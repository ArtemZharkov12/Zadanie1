# syntax=docker/dockerfile:1.2

# Etap 1: Obraz bazowy z Pythonem
FROM python:3.9-slim AS base

# Ustawienie katalogu roboczego w kontenerze
WORKDIR /app

# Instalacja zależności systemowych
RUN apt-get update && apt-get install -y \
    git \
    wget \
 && rm -rf /var/lib/apt/lists/*

# Skopiowanie plików aplikacji
COPY requirements.txt .

# Etap 2: Ostateczny obraz z kodem aplikacji
FROM python:3.9-slim AS final

# Ustawienie katalogu roboczego w kontenerze
WORKDIR /app

# Skopiowanie zależności z obrazu bazowego
COPY --from=base /app .

# Odsłuch na porcie, na którym działa serwer
EXPOSE 3000

# Zdrowotność aplikacji
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Uruchomienie serwera przy użyciu interpretera Pythona
CMD ["python", "server.py"]
