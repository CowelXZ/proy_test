import 'package:flutter/material.dart';
import 'package:proy_test/Administracion/A%C3%B1adirFunciones.dart';
import 'package:proy_test/Administracion/Funciones.dart';
import 'package:proy_test/Administracion/Peliculas.dart';
import 'package:proy_test/Administracion/Usuarios.dart';
import 'package:proy_test/Administracion/RegistrarPeliculas.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
        backgroundColor: const Color(0xFF022044),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(context, 'Administrar Usuarios', const Usuarios()),
              _buildMenuButton(context, 'Administrar Películas', const Peliculas()),
              _buildMenuButton(context, 'Registrar Película', const RPeliculas()),
              _buildMenuButton(context, 'Registrar Funciones', const AFunciones()),
              _buildMenuButton(context, 'Funciones', const ListaFunciones()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff14AE5C),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
