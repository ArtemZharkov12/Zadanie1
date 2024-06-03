# syntax=docker/dockerfile:1.2

# Stage 1: Базовый образ с Python
# Используем Python 3.11 на Alpine Linux в качестве базового образа для этапа сборки
FROM python:3.11-alpine AS base

# Устанавливаем рабочий каталог внутри контейнера
WORKDIR /app

# Устанавливаем git для клонирования репозитория
RUN apk add --no-cache git

# Клонируем репозиторий с кодом приложения
RUN --mount=type=cache,target=/root/.npm git clone https://github.com/ArtemZharkov12/Zadanie1.git .

# Копируем файл requirements и устанавливаем зависимости с оптимизацией кэша
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache \
    pip install -r requirements.txt

# Stage 2: Финальный образ с кодом приложения
# Используем Python 3.11 на Alpine Linux в качестве базового образа для финального этапа
FROM python:3.11-alpine AS final

# Устанавливаем рабочий каталог внутри контейнера
WORKDIR /app

# Копируем зависимости, установленные на этапе сборки, в финальный образ
COPY --from=base /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Копируем код приложения из этапа сборки в финальный образ
COPY server.py .

# Открываем порт, на котором будет работать сервер
EXPOSE 3000

# Добавляем healthcheck для проверки корректной работы сервера
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Запускаем сервер с помощью интерпретатора Python
CMD ["python", "server.py"]