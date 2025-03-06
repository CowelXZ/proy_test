const express = require('express');
const { connectDB } = require('./db'); // 🔹 Importamos connectDB

const app = express();
const PORT = 3000;

// Conectar a la base de datos
connectDB(); // 🔹 Llamamos la función antes de iniciar el servidor

app.get('/', (req, res) => {
    res.send('API con Node.js y SQL Server funcionando 🚀');
});

app.listen(PORT, () => {
    console.log(`🔥 Servidor corriendo en http://localhost:${PORT}`);
});
