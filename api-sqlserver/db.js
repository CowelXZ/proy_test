const sql = require('mssql');

const dbConfig = {
    server: 'DESKTOP-FDUT0ET', // El nombre de tu servidor
    database: 'CineDB', // Nombre de tu base de datos
    options: {
        trustServerCertificate: true,
        encrypt: false
    },
    authentication: {
        type: 'default', // Autenticación SQL
        options: {
            userName: 'cowelxz', // El nombre de usuario SQL
            password: 'contra12345' // La contraseña del usuario SQL
        }
    }
};

async function connectDB() {
    try {
        await sql.connect(dbConfig);
        console.log("✅ Conexión exitosa a SQL Server");
    } catch (error) {
        console.error("❌ Error de conexión:", error);
    }
}

module.exports = { sql, connectDB };
