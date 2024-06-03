# syntax=docker/dockerfile:1.2

# Etap 1: Obraz bazowy z Pythonem
# Użyj Pythona 3.9 na Alpine Linux jako obraz bazowy dla etapu budowy
FROM python:3.9-alpine AS base

# Ustaw katalog roboczy w kontenerze
WORKDIR /app

# Zainstaluj git do klonowania repozytorium
RUN apk add --no-cache git

# Sklonuj repozytorium zawierające kod aplikacji
RUN --mount=type=cache,target=/root/.npm git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Skopiuj plik wymagań i zainstaluj zależności z optymalizacją pamięci podręcznej
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install --no-cache-dir -r requirements.txt

# Etap 2: Ostateczny obraz z kodem aplikacji
# Użyj Pythona 3.9 na Alpine Linux jako obraz bazowy dla etapu końcowego
FROM python:3.9-alpine AS final

# Ustaw katalog roboczy w kontenerze
WORKDIR /app

# Skopiuj zainstalowane zależności z etapu budowy do ostatecznego obrazu
COPY --from=base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Skopiuj kod aplikacji z etapu budowy do ostatecznego obrazu
COPY server.py .

# Udostępnij port, na którym będzie działać serwer
EXPOSE 3000

# Dodaj mechanizm sprawdzający poprawność działania serwera
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Uruchom serwer przy użyciu interpretera Pythona
CMD ["python", "server.py"]