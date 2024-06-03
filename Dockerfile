# syntax=docker/dockerfile:1.2

# Etap 1: Bazowy obraz z Pythonem
FROM python:3.11-alpine AS base

# Ustawiamy katalog roboczy wewnątrz kontenera na /app
WORKDIR /app

# Instalujemy Git i необходимые пакеты для сборки зависимостей
RUN apk add --no-cache git build-base

# Копируем requirements.txt и устанавливаем зависимости с использованием кэша
COPY requirements.txt "flask==2.0.1 requests==2.25.1"
RUN --mount=type=cache,target=/root/.cache \
    pip install --no-cache-dir -r requirements.txt

# Klonujemy repozytorium z kodem aplikacji
RUN --mount=type=cache,target=/root/.npm git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Etap 2: Końcowy obraz z kodem aplikacji
FROM python:3.11-alpine AS final

# Ustawiamy katalog roboczy wewnątrz kontenera na /app
WORKDIR /app

# Копируем зависимости, установленные на этапе сборки
COPY --from=base /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Копируем код приложения
COPY --from=base /app /app

# Открываем порт 3000, на którym будет работать сервер
EXPOSE 3000

# Добавляем проверку состояния (health check)
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Запускаем сервер с использованием интерпретатора Python
CMD ["python", "server.py"]