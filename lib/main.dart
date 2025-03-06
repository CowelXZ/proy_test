import 'package:flutter/material.dart';
import 'package:proy_test/usuarios.dart'; // Asegúrate de importar el archivo correcto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Usuarios(), // Ahora inicia en la pantalla de Usuarios
    );
  }
}
