# syntax=docker/dockerfile:1.2

# Этап 1: Установка зависимостей с использованием Poetry
FROM python:3.9-slim AS builder

# Установка необходимых инструментов
RUN apt-get update && apt-get install -y \
    git \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Установка Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Добавление Poetry в PATH
ENV PATH="/root/.local/bin:$PATH"

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов для установки зависимостей
COPY pyproject.toml poetry.lock ./

# Установка зависимостей без установки самого проекта
RUN poetry install --no-root

# Этап 2: Финальный образ
FROM python:3.9-slim

# Копирование зависимостей из builder образа
COPY --from=builder /root/.local /root/.local
ENV PATH="/root/.local/bin:$PATH"

# Установка рабочего каталога
WORKDIR /app

# Копирование файлов приложения
COPY requirements.txt .

# Открытие порта, на котором работает сервер
EXPOSE 3000

# Проверка состояния приложения
HEALTHCHECK --interval=30s --timeout=3s CMD wget -q -O- http://localhost:3000 || exit 1

# Запуск сервера с использованием интерпретатора Python
CMD ["python", "server.py"]
