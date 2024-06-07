const express = require('express');
const app = express();
const fs = require('fs');
const path = require('path');

// Определяем маршрут для домашней страницы
app.get('/', (req, res) => {
  // Получаем IP-адрес клиента
  const clientIP = req.ip;
  
  // Получаем текущее время
  const currentTime = new Date().toLocaleString();
  
  // Создаем строку для журнала с IP-адресом клиента и временем доступа
  const logMessage = `Client IP: ${clientIP}, Access Time: ${currentTime}\n`;
  
  // Добавляем строку в файл server.log
  fs.appendFile(path.join(__dirname, 'server.log'), logMessage, (err) => {
    if (err) {
      console.error('Error writing to server.log:', err);
    }
  });
  
  // Отправляем HTML-ответ с IP-адресом клиента и текущим временем
  res.send(`<h1>Client IP: ${clientIP}</h1><p>Current Time: ${currentTime}</p>`);
});

// Запускаем сервер, если этот файл запущен как основной скрипт
if (require.main === module) {
  // Сервер будет слушать все IP-адреса (0.0.0.0) и порт 3000
  const port = process.env.PORT || 3000;
  app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });
}

// Экспортируем экземпляр приложения для использования в других модулях (например, тестах)
module.exports = app;
