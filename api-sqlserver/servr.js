const express = require('express');
const { connectDB, sql } = require('./db'); // Asegúrate de importar sql correctamente
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

// Conectar a la base de datos
connectDB(); // Llamamos la función antes de iniciar el servidor

// Middleware para leer el cuerpo de las solicitudes como JSON
app.use(bodyParser.json());

// Endpoint raíz para verificar la API
app.get('/', (req, res) => {
    res.send('API con Node.js y SQL Server funcionando 🚀');
});

// Endpoint para agregar un usuario
app.post('/addUser', async (req, res) => {
  const { nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos, departamento } = req.body;

  if (!nombre || !apellidos|| !telefono || !rfc || !usuario || !contrasena || !cumpleanos || !departamento) {
    return res.status(400).send({ message: 'Todos los campos son necesarios' });
  }

  try {
    // Usar un objeto request para la consulta
    const request = new sql.Request();
    // La consulta con los valores recibidos de la interfaz
    const query = `
      INSERT INTO Usuarios (nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos, departamento)
      VALUES (@nombre, @apellidos, @telefono, @rfc, @usuario, @contrasena, @cumpleanos, @departamento)
    `;
    
    // Asignar los parámetros a la consulta SQL
    request.input('nombre', sql.NVarChar, nombre);
    request.input('apellidos', sql.NVarChar, apellidos);
    request.input('telefono', sql.NVarChar, telefono);
    request.input('rfc', sql.NVarChar, rfc);
    request.input('usuario', sql.NVarChar, usuario);
    request.input('contrasena', sql.NVarChar, contrasena);
    request.input('cumpleanos', sql.Date, cumpleanos);  // Dependiendo del tipo de dato de cumpleanos (si es una fecha)
    request.input('departamento', sql.NVarChar, departamento);

    await request.query(query);

    res.status(200).send({ message: 'Usuario agregado con éxito' });
  } catch (error) {
    console.error('Error al agregar usuario:', error);
    res.status(500).send({ message: 'Hubo un error al agregar al usuario' });
  }
});

app.get('/getUsers', async (req, res) => {
  try {
    const { orderBy } = req.query;
    let orderClause = '';

    if (orderBy === 'Cumpleaños') {
      orderClause = 'ORDER BY cumpleanos ASC';
    } else if (orderBy === 'Fecha Registro') {
      orderClause = 'ORDER BY id DESC'; // Asumiendo que el ID es incremental
    } else if (orderBy === 'Departamento') {
      orderClause = 'ORDER BY departamento ASC';
    }

    const request = new sql.Request();
    const result = await request.query(`SELECT * FROM Usuarios ${orderClause}`);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error al obtener usuarios:', error);
    res.status(500).json({ message: 'Hubo un error al obtener los usuarios' });
  }
});

// Endpoint para eliminar un usuario
app.delete('/deleteUser/:id', async (req, res) => {
  try {
    const userId = req.params.id; // Obtener el ID desde la URL
    if (!userId) {
      return res.status(400).send({ message: 'ID de usuario es requerido' });
    }

    const request = new sql.Request();
    request.input('id', sql.Int, userId); // Asegurar que el ID es un entero

    const result = await request.query('DELETE FROM Usuarios WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      res.status(200).send({ message: 'Usuario eliminado con éxito' });
    } else {
      res.status(404).send({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error('Error al eliminar usuario:', error);
    res.status(500).send({ message: 'Error en el servidor' });
  }
});




// Iniciar el servidor
app.listen(PORT, () => {
    console.log(`🔥 Servidor corriendo en http://localhost:${PORT}`);
});
