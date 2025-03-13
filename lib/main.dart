import 'package:flutter/material.dart';
import 'package:proy_test/HomeScreen.dart'; // Importar la nueva pantalla de menú

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(), // Inicia en el nuevo menú principal
    );
  }
}
