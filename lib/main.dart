import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart'; // Importar el paquete
import 'package:proy_test/HomeScreen.dart';
import 'package:proy_test/Vistas/InicioSesion.dart'; // Importar la pantalla de inicio

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    const initialSize = Size(1000, 750); // Tamaño inicial de la ventana
    appWindow.size = initialSize;
    appWindow.title = "(BTS) Bite Technology System"; // Cambiar el nombre de la ventana
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: "BTS",
      debugShowCheckedModeBanner: false,
      home: const InicioSesion(), // Inicia en la pantalla de inicio
    );
  }
}