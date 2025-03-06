class DatabaseHelper {
  static Future<void> connect() async {
    final conn = Connection(
      host: 'DESKTOP-FDUT0ET\\MSSQLSERVER01',
      database: 'NombreDeTuBaseDeDatos',
      trustedConnection: true,  // Usa autenticación de Windows
    );

    try {
      await conn.open();
      print('Conexión exitosa a SQL Server');
    } catch (e) {
      print('Error de conexión: $e');
    } finally {
      await conn.close();
    }
  }
}
