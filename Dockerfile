# syntax=docker/dockerfile:1.2

# Etap 1: Bazowy obraz z Pythonem
FROM python:3.11-alpine AS base

# Ustawiamy katalog roboczy wewnątrz kontenera na /app
WORKDIR /app

# Instalujemy Git i aktualizujemy pip do najnowszej wersji
RUN apk add --no-cache git \
    && pip install --no-cache-dir --upgrade pip

# Klonujemy repozytorium z kodem aplikacji
RUN --mount=type=cache,target=/root/.npm git clone https://github.com/artemzharkov12/Zadanie1.git .

# Kopiujemy plik requirements.txt i instalujemy zależności z optymalizacją pamięci podręcznej
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install --no-cache-dir -r requirements.txt

# Etap 2: Końcowy obraz z kodem aplikacji
FROM python:3.11-alpine AS final

# Ustawiamy katalog roboczy wewnątrz kontenera na /app
WORKDIR /app

# Kopiujemy zależności zainstalowane na etapie budowy do obrazu końcowego
COPY --from=base /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Kopiujemy kod aplikacji (server.py) z etapu budowy do obrazu końcowego
COPY server.py .

# Otwieramy port 3000, na którym będzie działać serwer
EXPOSE 3000

# Dodajemy sprawdzanie stanu zdrowia (health check) w celu weryfikacji poprawności działania serwera
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Uruchamiamy serwer za pomocą interpretera Pythona
CMD ["python", "server.py"]
