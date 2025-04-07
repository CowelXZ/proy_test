const express = require('express');
const app = express();
const { connectDB, sql, config } = require('./db');
const bodyParser = require('body-parser');
const fs = require('fs'); // ✅ Importar módulo para manejar archivos


app.use(express.json()); // Middleware para analizar JSON

// Definición de rutas...

const PORT = 3000;
app.use('/uploads', express.static('uploads'));


//WAAAAA

app.use(express.json());

app.post('/login', async (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ message: 'Usuario y contraseña son requeridos' });
  }
  //add
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('usuario', sql.NVarChar, usuario)
      .input('contrasena', sql.NVarChar, contrasena)
      .query('SELECT * FROM Usuarios WHERE usuario = @usuario AND contrasena = @contrasena');
    console.log("📡 Resultado de la consulta:", result.recordset); // ✅ Verificar el resultado de la consulta
    if (result.recordset.length > 0) {
      const usuario = result.recordset[0];
      res.status(200).json({
        valido: true,
        message: 'Autenticación exitosa',
        usuario: {
          nombre: usuario.nombre,
          apellidos: usuario.apellidos,
          usuario: usuario.usuario
        }
      });
    }
    else {
      res.status(401).json({ valido: false, message: 'Usuario o contraseña inválidos' });
    }
  } catch (err) {
    console.error('Error en la consulta:', err);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});


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
    const { orderBy, departamento } = req.query;
    let query = `
      SELECT 
        id, 
        ISNULL(CONCAT(nombre, ' ', apellidos), 'Desconocido') AS nombre_completo, 
        telefono, 
        rfc, 
        usuario, 
        FORMAT(cumpleanos, 'yyyy-MM-dd') AS cumpleanos, 
        departamento 
      FROM Usuarios
    `;

    const request = new sql.Request();

    if (departamento && departamento !== "Todos") {
      query += ' WHERE departamento = @departamento';
      request.input('departamento', sql.NVarChar, departamento);
    }

    switch (orderBy) {
      case 'Cumpleaños':
        query += ' ORDER BY cumpleanos ASC';
        break;
      case 'Fecha Registro':
        query += ' ORDER BY id DESC';
        break;
      case 'Departamento':
        query += ' ORDER BY departamento ASC';
        break;
    }

    const result = await request.query(query);
    console.log("📡 Usuarios obtenidos:", result.recordset);
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
"TOP"
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
}); app.post('/addFunction', async (req, res) => {
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

// ✅ Agregar un proveedor con RFC
app.post('/addProveedor', async (req, res) => {
  try {
    const { nombre, correo, telefono, direccion, rfc } = req.body;

    if (!nombre || !correo || !telefono || !direccion || !rfc) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('correo', sql.NVarChar, correo);
    request.input('telefono', sql.NVarChar, telefono);
    request.input('direccion', sql.NVarChar, direccion);
    request.input('rfc', sql.NVarChar, rfc);

    await request.query(`
      INSERT INTO Proveedores (nombre, correo, telefono, direccion, rfc)
      VALUES (@nombre, @correo, @telefono, @direccion, @rfc)
    `);

    res.status(201).json({ message: '✅ Proveedor agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar proveedor:', error);
    res.status(500).json({ message: 'Error al agregar proveedor' });
  }
});

// ✅ Agregar un consumible
app.post('/addConsumible', async (req, res) => {
  try {
    const { nombre, proveedor, stock, unidad, precio_unitario, imagen } = req.body;

    if (!nombre || !proveedor || !stock || !unidad || !precio_unitario) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('proveedor', sql.NVarChar, proveedor);
    request.input('stock', sql.Int, stock);
    request.input('unidad', sql.NVarChar, unidad);
    request.input('precio_unitario', sql.Float, precio_unitario);
    request.input('imagen', sql.NVarChar, imagen || null);

    await request.query(`
      INSERT INTO Consumibles (nombre, proveedor, stock, unidad, precio_unitario, imagen)
      VALUES (@nombre, @proveedor, @stock, @unidad, @precio_unitario, @imagen)
    `);

    res.status(201).json({ message: '✅ Consumible agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar consumible:', error);
    res.status(500).json({ message: 'Error al agregar consumible' });
  }
});

// Obtener todos los consumibles
app.get('/getConsumibles', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT nombre FROM Consumibles');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error al obtener consumibles:', error);
    res.status(500).json({ message: 'Error al obtener consumibles' });
  }
});




// Obtener todos los proveedores
app.get('/getProveedores', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT nombre FROM Proveedores');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener proveedores:', error);
    res.status(500).json({ message: 'Error al obtener proveedores' });
  }
});

app.post('/addIntermedio', async (req, res) => {
  try {
    const { nombre, imagen, cantidad_producida, unidad, costo_total_estimado, consumibles_usados } = req.body;

    if (!nombre || !cantidad_producida || !unidad || !costo_total_estimado || !consumibles_usados) {
      return res.status(400).json({ message: 'Todos los campos son obligatorios.' });
    }

    // Insertar en la tabla Intermedios
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('imagen', sql.NVarChar, imagen || null);
    request.input('cantidad_producida', sql.Float, cantidad_producida);
    request.input('unidad', sql.NVarChar, unidad);
    request.input('costo_total_estimado', sql.Float, costo_total_estimado);

    const result = await request.query(`
      INSERT INTO Intermedios (nombre, imagen, cantidad_producida, unidad, costo_total_estimado)
      OUTPUT INSERTED.id
      VALUES (@nombre, @imagen, @cantidad_producida, @unidad, @costo_total_estimado)
    `);

    const intermedioId = result.recordset[0].id;

    // Insertar consumibles usados
    for (const c of consumibles_usados) {
      const reqC = new sql.Request();
      reqC.input('intermedio_id', sql.Int, intermedioId);
      reqC.input('nombre', sql.NVarChar, c.nombre);
      reqC.input('cantidad_usada', sql.Float, c.cantidad_usada);
      await reqC.query(`
        INSERT INTO Intermedios_Consumibles (intermedio_id, nombre, cantidad_usada)
        VALUES (@intermedio_id, @nombre, @cantidad_usada)
      `);
    }

    res.status(201).json({ message: '✅ Intermedio guardado exitosamente' });
  } catch (error) {
    console.error('❌ Error al guardar intermedio:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
});

app.get('/getIntermedios', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        I.id,
        I.nombre,
        I.imagen,
        I.cantidad_producida,
        I.unidad,
        I.costo_total_estimado,
        (
          SELECT 
            nombre, 
            cantidad_usada 
          FROM Intermedios_Consumibles IC 
          WHERE IC.intermedio_id = I.id 
          FOR JSON PATH
        ) AS consumibles
      FROM Intermedios I
      ORDER BY I.id DESC
    `);

    // Parsear los campos JSON de consumibles
    const intermedios = result.recordset.map(row => ({
      ...row,
      consumibles: row.consumibles ? JSON.parse(row.consumibles) : []
    }));

    res.status(200).json(intermedios);
  } catch (error) {
    console.error("❌ Error al obtener intermedios:", error);
    res.status(500).json({ message: 'Error al obtener intermedios' });
  }
});
app.get('/getAllConsumibles', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        nombre,
        proveedor,
        stock,
        precio_unitario
      FROM Consumibles
      ORDER BY nombre ASC
    `);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener consumibles:', error);
    res.status(500).json({ message: 'Error al obtener consumibles' });
  }
});

app.get('/getAllProveedores', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        nombre,
        telefono,
        correo,
        direccion,
        rfc
      FROM Proveedores
      ORDER BY nombre ASC
    `);
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener proveedores:', error);
    res.status(500).json({ message: 'Error al obtener proveedores' });
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
