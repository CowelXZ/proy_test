import 'package:flutter/material.dart';
import 'package:proy_test/Administracion/A%C3%B1adirFunciones.dart';
import 'package:proy_test/Administracion/Extras.dart';
import 'package:proy_test/Administracion/Funciones.dart';
import 'package:proy_test/Administracion/Peliculas.dart';
import 'package:proy_test/Administracion/RegistroCombos.dart';
import 'package:proy_test/Administracion/RegistroConsumibles.dart';
import 'package:proy_test/Administracion/RegistroIntermedios.dart';
import 'package:proy_test/Administracion/RegistroProductos.dart';
import 'package:proy_test/Administracion/RegistroProovedores.dart';
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
              _buildMenuButton(context, 'Registrar Combos', const Registrocombos()),
              _buildMenuButton(context, 'Registrar Consumibles', const Registroconsumibles()),
              _buildMenuButton(context, 'Registro Intermedios', const Registrointermedios()),
              _buildMenuButton(context, 'Registro Productos', const Registroproductos()),
              _buildMenuButton(context, 'Registro Proveedores', const Rproveedores()),
              _buildMenuButton(context, 'Registro Extras', const Extras()),

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
