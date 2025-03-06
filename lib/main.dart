import 'package:flutter/material.dart';
import 'package:proy_test/RegistrarUsuario.dart'; // Asegúrate de importar tu archivo de RegistroU si es que está en otro archivo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Opcional, para quitar el banner de debug
      home: const RegistroU(), // Aquí ponemos directamente la pantalla de RegistroU como la principal
    );
  }
}
