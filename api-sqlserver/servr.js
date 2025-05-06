const express = require('express');
const app = express();
const { connectDB, sql, config } = require('./db');
const bodyParser = require('body-parser');
const fs = require('fs'); // ✅ Importar módulo para manejar archivos

const multer = require('multer'); // ✅ Importar multer para manejar archivos subidos
const uploads = multer({ dest: 'uploads/' }); // carpeta temporal para los posters


app.use(express.json()); // Middleware para analizar JSON

// Definición de rutas.
const PORT = 3000;
app.use('/uploads', express.static('uploads'));
app.use(express.json());

app.post('/login', async (req, res) => {
  const { usuario, contrasena } = req.body;

  if (!usuario || !contrasena) {
    return res.status(400).json({ message: 'Usuario y contraseña son requeridos' });
  }
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
app.post('/addMovie', uploads.single('poster'), async (req, res) => {
  let { titulo, director, duracion, idioma, subtitulos, genero, clasificacion, sinopsis } = req.body;
  const posterFile = req.file;

  if (!titulo || !director || !duracion || !idioma || !genero || !clasificacion || !sinopsis) {
    return res.status(400).json({ message: "Todos los campos son obligatorios." });
  }

  const duracionValida = /^([01]?\d|2[0-3]):[0-5]\d:[0-5]\d$/.test(duracion);
  if (!duracionValida) {
    return res.status(400).json({ message: "Formato de duración inválido. Usa HH:mm:ss" });
  }

  try {
    const request = new sql.Request();
    request.input('titulo', sql.NVarChar, titulo);
    request.input('director', sql.NVarChar, director);
    request.input('duracion', sql.NVarChar, duracion);
    request.input('idioma', sql.NVarChar, idioma);
    request.input('subtitulos', sql.Bit, subtitulos === "Si" ? 1 : 0);
    request.input('genero', sql.NVarChar, genero);
    request.input('clasificacion', sql.NVarChar, clasificacion);
    request.input('sinopsis', sql.NVarChar, sinopsis);

    if (posterFile) {
      const posterBuffer = fs.readFileSync(posterFile.path);
      request.input('poster', sql.VarBinary(sql.MAX), posterBuffer);
    } else {
      request.input('poster', sql.VarBinary(sql.MAX), null);
    }
//recetas
    await request.query(`
      INSERT INTO Pelicula (titulo, director, duracion, idioma, subtitulos, genero, clasificacion, sinopsis, poster)
      VALUES (@titulo, @director, @duracion, @idioma, @subtitulos, @genero, @clasificacion, @sinopsis, @poster)
    `);

    res.status(201).json({ message: "Película registrada con éxito" });
  } catch (error) {
    console.error("❌ Error al registrar película:", error);
    res.status(500).json({ message: "Error en el servidor" });
  }
});


app.get('/getMovies', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT * FROM Pelicula ORDER BY ID_Pelicula DESC');

    // Mapea cada registro para añadir posterBase64
    const peliculas = result.recordset.map(row => ({
      ID_Pelicula:    row.ID_Pelicula,
      Titulo:         row.Titulo,
      Director:       row.Director,
      Duracion:       row.Duracion,
      Idioma:         row.Idioma,
      Subtitulos:     row.Subtitulos,
      Genero:         row.Genero,
      Clasificacion:  row.Clasificacion,
      Sinopsis:       row.Sinopsis,
      posterBase64:   row.Poster ? row.Poster.toString('base64') : '',
    }));

    res.status(200).json(peliculas);
  } catch (error) {
    console.error("❌ Error al obtener películas:", error);
    res.status(500).json({ message: "Error al obtener películas" });
  }
});



app.delete('/deleteMovie/:ID_Pelicula', async (req, res) => {
  try {
    const movieId = parseInt(req.params.ID_Pelicula, 10); // <--- ESTA ES LA CLAVE

    if (isNaN(movieId)) {
      return res.status(400).json({ message: 'ID de película inválido' });
    }

    const request = new sql.Request();
    request.input('ID_Pelicula', sql.Int, movieId);

    const result = await request.query('DELETE FROM Pelicula WHERE ID_Pelicula = @ID_Pelicula');

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
});

app.post('/addFunction', async (req, res) => {
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

app.get('/getConsumiblesParaReceta', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query('SELECT id, nombre, unidad FROM Consumibles');
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('Error al obtener consumibles:', error);
    res.status(500).json({ message: 'Error al obtener consumibles' });
  }
});


app.delete('/deleteConsumible/:nombre', async (req, res) => {
  try {
    const nombre = req.params.nombre;
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    const result = await request.query('DELETE FROM Consumibles WHERE nombre = @nombre');
    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: 'Consumible eliminado con éxito' });
    } else {
      res.status(404).json({ message: 'Consumible no encontrado' });
    }
  } catch (error) {
    console.error('Error al eliminar consumible:', error);
    res.status(500).json({ message: 'Error al eliminar consumible' });
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

app.delete('/deleteProveedor/:nombre', async (req, res) => {
  const { nombre } = req.params;
  try {
    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    const result = await request.query('DELETE FROM Proveedores WHERE nombre = @nombre');

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ mensaje: 'Proveedor eliminado con éxito' });
    } else {
      res.status(404).json({ mensaje: 'Proveedor no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar proveedor:', error);
    res.status(500).json({ mensaje: 'Error al eliminar el proveedor', error });
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

    for (const c of consumibles_usados) {
      const reqInsert = new sql.Request();
      reqInsert.input('intermedio_id', sql.Int, intermedioId);
      reqInsert.input('nombre', sql.NVarChar, c.nombre);
      reqInsert.input('cantidad_usada', sql.Float, c.cantidad_usada);
      await reqInsert.query(`
        INSERT INTO Intermedios_Consumibles (intermedio_id, nombre, cantidad_usada)
        VALUES (@intermedio_id, @nombre, @cantidad_usada)
      `);

      const reqUpdate = new sql.Request();
      reqUpdate.input('nombre', sql.NVarChar, c.nombre);
      reqUpdate.input('cantidad_usada', sql.Float, c.cantidad_usada);
      await reqUpdate.query(`
        UPDATE Consumibles
        SET stock = stock - @cantidad_usada
        WHERE nombre = @nombre
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

app.delete('/deleteIntermedio/:id', async (req, res) => {
  const intermedioId = parseInt(req.params.id, 10);

  if (isNaN(intermedioId)) {
    return res.status(400).json({ message: 'ID de intermedio inválido' });
  }

  try {
    const request = new sql.Request();
    request.input('id', sql.Int, intermedioId);

    // Primero eliminar los consumibles relacionados
    await request.query('DELETE FROM Intermedios_Consumibles WHERE intermedio_id = @id');

    // Luego eliminar el intermedio
    const result = await request.query('DELETE FROM Intermedios WHERE id = @id');

    if (result.rowsAffected[0] > 0) {
      res.status(200).json({ message: '✅ Intermedio eliminado con éxito' });
    } else {
      res.status(404).json({ message: 'Intermedio no encontrado' });
    }
  } catch (error) {
    console.error('❌ Error al eliminar intermedio:', error);
    res.status(500).json({ message: 'Error al eliminar intermedio' });
  }
});


app.get('/getAllConsumibles', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        id,
        nombre,
        proveedor,
        stock,
        unidad,
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


app.post('/addReceta', async (req, res) => {
  const { nombre, porcion, unidad, consumibles } = req.body;

  if (!nombre || !porcion || !unidad || !consumibles || !Array.isArray(consumibles)) {
    return res.status(400).json({ mensaje: 'Datos incompletos o incorrectos' });
  }

  const transaction = new sql.Transaction();

  try {
    await transaction.begin();

    const requestReceta = new sql.Request(transaction);
    requestReceta.input('nombre', sql.NVarChar, nombre);
    requestReceta.input('porcion', sql.Float, porcion);
    requestReceta.input('unidad', sql.NVarChar, unidad);

    const resultReceta = await requestReceta.query(
      'INSERT INTO Recetas (nombre, porcion, unidad) OUTPUT INSERTED.id VALUES (@nombre, @porcion, @unidad)'
    );

    const recetaId = resultReceta.recordset[0].id;

    for (const consumible of consumibles) {
      const requestConsumible = new sql.Request(transaction);
      requestConsumible.input('receta_id', sql.Int, recetaId);
      requestConsumible.input('consumible_id', sql.Int, consumible.id);
      requestConsumible.input('cantidad_usada', sql.Float, consumible.cantidad);

      await requestConsumible.query(
        'INSERT INTO Recetas_Consumibles (receta_id, consumible_id, cantidad_usada) VALUES (@receta_id, @consumible_id, @cantidad_usada)'
      );
    }

    await transaction.commit();
    res.status(201).json({ mensaje: 'Receta creada con éxito' });
  } catch (error) {
    await transaction.rollback();
    console.error('Error al crear la receta:', error);
    res.status(500).json({ mensaje: 'Error interno del servidor', error });
  }
});
///////////////////////////////////


app.use('/images', express.static(path.join(__dirname, '../images')));
//Peliculas
app.get('/funciones', async (req, res) => {
  const fecha = req.query.fecha; // e.g. 2025-04-26
  if (!fecha) return res.status(400).send("Falta la fecha en el query string");

  try {
    await connectDB();
    const result = await sql.query(`
            SELECT 
    P.id_Pelicula,
    P.titulo,
    P.genero,
    P.clasificacion,
    CONVERT(varchar(5), P.duracion, 108) AS duracion,
    P.poster,
    F.idioma,
    CONVERT(varchar(5), F.horario, 108) AS horario,
    CAST(F.sala AS VARCHAR) AS sala,
    F.tipo_sala
FROM Funciones F
INNER JOIN Pelicula P ON F.id_pelicula = P.id_Pelicula
WHERE F.fecha = '${fecha}'
ORDER BY P.id_Pelicula, F.idioma, F.horario

        `);
    //Error al

    const agrupado = {};

    result.recordset.forEach(row => {
      const id = row.id_Pelicula;

      if (!agrupado[id]) {
        agrupado[id] = {
          titulo: row.titulo,
          genero: row.genero,
          clasificacion: row.clasificacion,
          duracion: row.duracion,
          poster: `/images/${row.poster}`,
          funciones: {}
        };
      }


      if (!agrupado[id].funciones[row.idioma]) {
        agrupado[id].funciones[row.idioma] = [];
      }

      agrupado[id].funciones[row.idioma].push({
        horario: row.horario,
        sala: row.sala,
        tipo_sala: (row.tipo_sala === null || row.tipo_sala === undefined) ? '2D' : row.tipo_sala
      });
    });


    res.json(Object.values(agrupado));
  } catch (error) {
    console.error("❌ Error al consultar funciones:", error);
    res.status(500).send(`Error al obtener funciones: ${error.message}`);
  }

});

app.get('/tiposboletos', async (req, res) => {
  const fecha = req.query.fecha;
  const tipoSala = req.query.tipoSala;

  if (!fecha || !tipoSala) {
    return res.status(400).send("Falta fecha o tipoSala en el query string");
  }

  try {
    await connectDB();
    const result = await sql.query(`
            SELECT 
                id_boleto,
                nombre,
                CASE 
                    WHEN fecha_especial IS NULL THEN 
                        CASE WHEN '${tipoSala}' = '2D' THEN precio_2D ELSE precio_3D END
                    WHEN fecha_especial = '${fecha}' THEN 
                        CASE WHEN '${tipoSala}' = '2D' THEN precio_2D ELSE precio_3D END
                    ELSE NULL
                END AS precio
            FROM TiposBoletos
        `);

    const boletos = result.recordset.filter(row => row.precio !== null);

    res.json(boletos);
  } catch (error) {
    console.error("❌ Error al consultar tipos de boletos:", error);
    res.status(500).send("Error al obtener tipos de boletos");
  }
});

app.post('/addMiembro', async (req, res) => {
  const { nombre, apellido, telefono, direccion, ine, tipo_membresia } = req.body;

  try {
    await connectDB();
    await sql.query`
        INSERT INTO Miembros (nombre, apellido, telefono, direccion, ine, tipo_membresia)
        VALUES (${nombre}, ${apellido}, ${telefono}, ${direccion}, ${ine}, ${tipo_membresia})
      `;
    res.status(201).send('Miembro agregado exitosamente');
  } catch (error) {
    console.error('Error al agregar miembro:', error);
    res.status(500).send('Error al agregar miembro');
  }
});

app.get('/miembros', async (req, res) => {
  try {
    await connectDB();
    const result = await sql.query(`
            SELECT id_miembro, nombre, apellido, telefono, direccion, ine, tipo_membresia
            FROM Miembros
        `);
    res.json(result.recordset);
  } catch (error) {
    console.error('Error al obtener miembros:', error);
    res.status(500).send('Error al obtener miembros');
  }
});


app.delete('/miembros/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await connectDB();
    await sql.query`
        DELETE FROM Miembros WHERE id_miembro = ${id}
      `;
    res.status(200).send('Miembro eliminado exitosamente');
  } catch (error) {
    console.error('Error al eliminar miembro:', error);
    res.status(500).send('Error al eliminar miembro');
  }
});


app.put('/miembros/:id', async (req, res) => {
  const { id } = req.params;
  const { nombre, apellido, telefono, direccion, ine, tipo_membresia } = req.body;

  try {
    await connectDB();
    await sql.query`
        UPDATE Miembros
        SET
          nombre = ${nombre},
          apellido = ${apellido},
          telefono = ${telefono},
          direccion = ${direccion},
          ine = ${ine},
          tipo_membresia = ${tipo_membresia}
        WHERE id_miembro = ${id}
      `;
    res.status(200).send('Miembro actualizado exitosamente');
  } catch (error) {
    console.error('Error al actualizar miembro:', error);
    res.status(500).send('Error al actualizar miembro');
  }
});

app.get('/miembroTelefono/:telefono', async (req, res) => {
  const { telefono } = req.params;

  try {
    await connectDB();
    const result = await sql.query`
        SELECT id_miembro, nombre, tipo_membresia, cashback_acumulado
        FROM Miembros
        WHERE telefono = ${telefono}
      `;

    if (result.recordset.length > 0) {
      res.json(result.recordset[0]);
    } else {
      res.status(404).send('Miembro no encontrado');
    }
  } catch (error) {
    console.error('Error al buscar miembro:', error);
    res.status(500).send('Error al buscar miembro');
  }
});


app.post('/pago', async (req, res) => {
  const {
    id_miembro,
    nombre_cliente,
    monto_total,
    monto_recibido,
    cambio,
    tipo_pago,
    cashback_generado
  } = req.body;

  try {
    await connectDB();
    await sql.query`
            INSERT INTO Pagos (id_miembro, nombre_cliente, monto_total, monto_recibido, cambio, tipo_pago, cashback_generado)
            VALUES (${id_miembro}, ${nombre_cliente}, ${monto_total}, ${monto_recibido}, ${cambio}, ${tipo_pago}, ${cashback_generado})
        `;

    if (id_miembro && cashback_generado > 0) {
      await sql.query`
                UPDATE Miembros
                SET cashback_acumulado = cashback_acumulado + ${cashback_generado}
                WHERE id_miembro = ${id_miembro}
            `;
    }

    res.status(201).send('Pago registrado exitosamente');
  } catch (error) {
    console.error('Error al registrar pago:', error);
    res.status(500).send('Error al registrar pago');
  }
});

app.get('/asientosOcupados', async (req, res) => {
  const { fecha, horario, sala } = req.query;

  try {
    await connectDB();
    const result = await sql.query`
        SELECT asientos_ocupados
        FROM Funciones
        WHERE fecha = ${fecha} AND horario = ${horario} AND sala = ${sala}
      `;

    if (result.recordset.length > 0) {
      res.json(result.recordset[0]);
    } else {
      res.status(404).send('No se encontraron asientos ocupados');
    }
  } catch (error) {
    console.error('Error al obtener asientos ocupados:', error);
    res.status(500).send('Error al obtener asientos ocupados');
  }
});


app.put('/actualizarAsientosVendidos', async (req, res) => {
  const { fecha, horario, sala, nuevos_asientos } = req.body;

  try {
    await connectDB();

    const resultado = await sql.query`
        SELECT asientos_ocupados
        FROM Funciones
        WHERE fecha = ${fecha} AND horario = ${horario} AND sala = ${sala}
      `;

    let asientosActuales = '';
    if (resultado.recordset.length > 0) {
      asientosActuales = resultado.recordset[0].asientos_ocupados || '';
    }

    let asientosCombinados = asientosActuales
      ? asientosActuales + ',' + nuevos_asientos
      : nuevos_asientos;

    await sql.query`
        UPDATE Funciones
        SET asientos_ocupados = ${asientosCombinados}
        WHERE fecha = ${fecha} AND horario = ${horario} AND sala = ${sala}
      `;

    res.status(200).send('Asientos actualizados exitosamente');
  } catch (error) {
    console.error('Error al actualizar asientos vendidos:', error);
    res.status(500).send('Error al actualizar asientos vendidos');
  }
});

app.post('/addProducto', async (req, res) => {
  try {
    const {
      nombre,
      tamano,
      porcionCantidad,
      porcionUnidad,
      stock,
      precio,
      imagen
    } = req.body;

    // Validación básica de campos obligatorios
    if (
      !nombre ||
      !stock ||
      !precio
    ) {
      return res.status(400).json({ message: '🌟 nombre, stock y precio son obligatorios' });
    }

    const request = new sql.Request();
    request.input('nombre', sql.NVarChar, nombre);
    request.input('tamano', sql.NVarChar, tamano || null);
    request.input('porcionCantidad', sql.Decimal, porcionCantidad || 0);
    request.input('porcionUnidad', sql.NVarChar, porcionUnidad || null);
    request.input('stock', sql.Int, stock);
    request.input('precio', sql.Decimal, precio);
    request.input('imagen', sql.NVarChar, imagen || null);

    await request.query(`
        INSERT INTO Productos
          (nombre, tamano, porcionCantidad, porcionUnidad, stock, precio, imagen)
        VALUES
          (@nombre, @tamano, @porcionCantidad, @porcionUnidad, @stock, @precio, @imagen)
      `);

    res.status(201).json({ message: '✅ Producto agregado con éxito' });
  } catch (error) {
    console.error('❌ Error al agregar producto:', error);
    res.status(500).json({ message: 'Error al agregar producto' });
  }
});

// 👉 GET para traer todos los productos
app.get('/getAllProductos', async (req, res) => {
  try {
    const request = new sql.Request();
    const result = await request.query(`
      SELECT 
        idProducto,
        nombre,
        stock,
        precio,
        imagen
      FROM dbo.Productos
    `);
    // result.recordset es un array de objetos con tus filas
    res.status(200).json(result.recordset);
  } catch (error) {
    console.error('❌ Error al obtener productos:', error);
    res
      .status(500)
      .json({ message: 'Error al obtener productos', error: error.message });
  }
});


