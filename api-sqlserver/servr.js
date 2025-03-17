const express = require('express');
const { connectDB, sql } = require('./db'); // Importar SQL correctamente
const bodyParser = require('body-parser');
const fs = require('fs'); // ✅ Importar módulo para manejar archivos
const app = express();
const PORT = 3000;
app.use('/uploads', express.static('uploads'));

// Conectar a la base de datos con manejo de errores
connectDB().catch((err) => {
  console.error('❌ Error al conectar a la BD:', err);
  process.exit(1); // Salir si la conexión falla
});

// Middleware
app.use(bodyParser.json());

// ✅ Endpoint de Prueba
app.get('/', (req, res) => {
  res.send('API con Node.js y SQL Server funcionando 🚀');
});

// ✅ Agregar un usuario
app.post('/addUser', async (req, res) => {
  try {
    const { nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos, departamento } = req.body;

    if (!nombre || !apellidos || !telefono || !rfc || !usuario || !contrasena || !cumpleanos || !departamento) {
      return res.status(400).json({ message: 'Todos los campos son necesarios' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('apellidos', sql.NVarChar, apellidos);
    request.input('telefono', sql.NVarChar, telefono);
    request.input('rfc', sql.NVarChar, rfc);
    request.input('usuario', sql.NVarChar, usuario);
    request.input('contrasena', sql.NVarChar, contrasena);
    request.input('cumpleanos', sql.Date, cumpleanos);
    request.input('departamento', sql.NVarChar, departamento);

    await request.query(`
            INSERT INTO Usuarios (nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos, departamento)
            VALUES (@nombre, @apellidos, @telefono, @rfc, @usuario, @contrasena, @cumpleanos, @departamento)
        `);

    res.status(201).json({ message: '✅ Usuario agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar usuario:', error);
    res.status(500).json({ message: 'Error al agregar usuario' });
  }
});

// ✅ Obtener usuarios con orden dinámico
app.get('/getUsers', async (req, res) => {
  try {
    const { orderBy } = req.query;
    let orderClause = '';

    switch (orderBy) {
      case 'Cumpleaños':
        orderClause = 'ORDER BY cumpleanos ASC';
        break;
      case 'Fecha Registro':
        orderClause = 'ORDER BY id DESC'; // Suponiendo que el ID es incremental
        break;
      case 'Departamento':
        orderClause = 'ORDER BY departamento ASC';
        break;
    }

    const request = new sql.Request();
    const result = await request.query(`SELECT * FROM Usuarios ${orderClause}`);

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener usuarios:', error);
    res.status(500).json({ message: 'Error al obtener los usuarios' });
  }
});

// ✅ Eliminar un usuario
app.delete('/deleteUser/:id', async (req, res) => {
  try {
    const userId = parseInt(req.params.id, 10);
    if (isNaN(userId)) {
      return res.status(400).json({ message: 'ID inválido' });
    }

    const request = new sql.Request();
    request.input('id', sql.Int, userId);

    const result = await request.query('DELETE FROM Usuarios WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: '✅ Usuario eliminado con éxito' });
    } else {
      res.status(404).json({ message: 'Usuario no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar usuario:', error);
    res.status(500).json({ message: 'Error al eliminar usuario' });
  }
});

app.post('/addMovie', async (req, res) => {
  let { titulo, director, duracion, idiomas, subtitulos, genero, clasificacion, sinopsis, poster } = req.body;

  console.log("📥 Datos recibidos:", { titulo, director, duracion, idiomas, genero, clasificacion, sinopsis });

  if (!titulo || !director || !duracion || !idiomas || !genero || !clasificacion || !sinopsis) {
    return res.status(400).json({ message: "Todos los campos son obligatorios." });
  }

  console.log("⏳ Duración antes de validación:", duracion);

  if (!duracion.trim()) {
    console.log("⛔ Error: Duración vacía");
    return res.status(400).json({ message: "Duración no puede estar vacía." });
  }

  const duracionValida = /^([01]?\d|2[0-3]):[0-5]\d:[0-5]\d$/.test(duracion);
  if (!duracionValida) {
    console.log("⛔ Error: Duración con formato incorrecto →", duracion);
    return res.status(400).json({ message: "Formato de duración inválido. Usa HH:mm:ss" });
  }

  try {
    console.log("✅ Insertando duración en SQL:", duracion);
    
    const request = new sql.Request();
    request.input('titulo', sql.NVarChar, titulo);
    request.input('director', sql.NVarChar, director);
    request.input('duracion', sql.NVarChar, duracion); // ✅ Enviar como string
    request.input('idiomas', sql.NVarChar, idiomas);
    request.input('subtitulos', sql.Bit, subtitulos === "Si" ? 1 : 0);
    request.input('genero', sql.NVarChar, genero);
    request.input('clasificacion', sql.NVarChar, clasificacion);
    request.input('sinopsis', sql.NVarChar, sinopsis);
    request.input('poster', sql.NVarChar, poster || null);

    await request.query(`
          INSERT INTO Peliculas (titulo, director, duracion, idiomas, subtitulos, genero, clasificacion, sinopsis, poster)
          VALUES (@titulo, @director, @duracion, @idiomas, @subtitulos, @genero, @clasificacion, @sinopsis, @poster)
      `);

    console.log("✅ Película registrada con éxito:", titulo);
    res.status(201).json({ message: "Película registrada con éxito" });
  } catch (error) {
    console.error("❌ Error al registrar película:", error);
    res.status(500).json({ message: "Error en el servidor" });
  }
});

app.get('/getMovies', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT * FROM Peliculas ORDER BY id DESC');

    res.status(200).json(result.recordset);
  } catch (error) {
    console.error("❌ Error al obtener películas:", error);
    res.status(500).json({ message: "Error al obtener películas" });
  }
});

app.delete('/deleteMovie/:id', async (req, res) => {
  try {
      const movieId = parseInt(req.params.id, 10);

      if (isNaN(movieId)) {
          return res.status(400).json({ message: 'ID de película inválido' });
      }

      const request = new sql.Request();
      request.input('id', sql.Int, movieId);

      const result = await request.query('DELETE FROM Peliculas WHERE id = @id');

      if (result.rowsAffected[0] > 0) {
          console.log(`✅ Película con ID ${movieId} eliminada`);
          res.status(200).json({ message: 'Película eliminada con éxito' });
      } else {
          console.log(`⚠️ No se encontró la película con ID ${movieId}`);
          res.status(404).json({ message: 'Película no encontrada' });
      }
  } catch (error) {
      console.error('❌ Error al eliminar película:', error);
      res.status(500).json({ message: 'Error al eliminar película' });
  }
});app.post('/addFunction', async (req, res) => {
  try {
    let { titulo, horario, fecha, sala, tipo_sala, idioma, poster } = req.body;

    console.log("📥 Datos recibidos:", { titulo, horario, fecha, sala, tipo_sala, idioma, poster });

    if (!titulo || !horario || !fecha || !sala || !tipo_sala || !idioma) {
      return res.status(400).json({ message: "Todos los campos son obligatorios." });
    }

    // Validar y formatear horario
    const horarioValido = /^([01]?\d|2[0-3]):[0-5]\d:[0-5]\d$/.test(horario);
    if (!horarioValido) {
      console.log("⛔ Error: Formato de horario incorrecto →", horario);
      return res.status(400).json({ message: "Formato de horario inválido. Usa HH:mm:ss" });
    }

    console.log("⏳ Horario formateado para SQL:", horario);

    const request = new sql.Request();
    request.input('titulo', sql.NVarChar, titulo);
    request.input('horario', sql.NVarChar, horario); // Enviamos como string válido
    request.input('fecha', sql.Date, fecha);
    request.input('sala', sql.Int, sala);
    request.input('tipo_sala', sql.NVarChar, tipo_sala);
    request.input('idioma', sql.NVarChar, idioma);
    request.input('poster', sql.NVarChar, poster || null);

    await request.query(`
      INSERT INTO Funciones (titulo, horario, fecha, sala, tipo_sala, idioma, poster)
      VALUES (@titulo, @horario, @fecha, @sala, @tipo_sala, @idioma, @poster)
    `);

    console.log("✅ Función agregada con éxito:", titulo);
    res.status(201).json({ message: "✅ Función agregada con éxito" });

  } catch (error) {
    console.error("❌ Error al agregar función:", error);
    res.status(500).json({ message: "Error en el servidor" });
  }
});

app.get('/getFunctions', async (req, res) => {
  try {
    console.log("📡 Obteniendo funciones...");
    const request = new sql.Request();
    const result = await request.query('SELECT * FROM Funciones ORDER BY fecha DESC, horario ASC');

    console.log("✅ Funciones obtenidas:", result.recordset.length);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error("❌ Error al obtener funciones:", error);
    res.status(500).json({ message: "Error al obtener funciones" });
  }
});

app.delete('/deleteFunction/:id', async (req, res) => {
  try {
    const functionId = parseInt(req.params.id, 10);
    if (isNaN(functionId)) {
      return res.status(400).json({ message: 'ID inválido' });
    }

    console.log("🗑️ Eliminando función con ID:", functionId);

    const request = new sql.Request();
    request.input('id', sql.Int, functionId);
    const result = await request.query('DELETE FROM Funciones WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      console.log("✅ Función eliminada con éxito:", functionId);
      res.status(200).json({ message: "✅ Función eliminada con éxito" });
    } else {
      console.log("⚠️ Función no encontrada:", functionId);
      res.status(404).json({ message: "Función no encontrada" });
    }
  } catch (error) {
    console.error("❌ Error al eliminar función:", error);
    res.status(500).json({ message: "Error al eliminar función" });
  }
});



//Muerte Mentalconst fs = require('fs');
const multer = require('multer');
const path = require('path');

// 🔥 Verifica que la carpeta "uploads/" existe, si no, la crea
const uploadPath = 'uploads/';
if (!fs.existsSync(uploadPath)) {
  fs.mkdirSync(uploadPath, { recursive: true });
}

// Configurar almacenamiento de imágenes en la carpeta "uploads"
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadPath); // ✅ Guarda las imágenes en "uploads/"
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // ✅ Nombre único
  }
});
//uploadImage
const upload = multer({ storage });

// 📌 Endpoint para subir imágenes
app.post('/uploadImage', upload.single('poster'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: "No se subió ninguna imagen" });
  }
  
  const imageUrl = `http://localhost:3000/uploads/${req.file.filename}`;
  res.status(200).json({ imageUrl });
});



app.use((err, req, res, next) => {
  console.error('❌ Error inesperado:', err);
  res.status(500).json({ message: 'Error interno del servidor' });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
});
