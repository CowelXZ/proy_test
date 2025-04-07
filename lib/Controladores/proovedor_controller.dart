import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:proy_test/Models/proovedor_model.dart';
import 'package:proy_test/Vistas/Menu.dart';
import '../HomeScreen.dart';

class ProveedorController {
  final BuildContext context;

  ProveedorController(this.context);

  Future<void> guardarProveedor(Proveedor proveedor) async {
    final url = Uri.parse('http://localhost:3000/addProveedor');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(proveedor.toJson()),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Proveedor agregado con éxito'),
            backgroundColor: Color.fromARGB(255, 0, 255, 0),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Menu()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al agregar proveedor')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error de conexión: $error')),
      );
    }
  }

  Future<List> fetchProveedores() async {
    final url = Uri.parse('http://localhost:3000/getAllProveedores');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((p) {
          try {
            return Proveedor.fromJson(p);
          } catch (e) {
            print("⚠️ Error al parsear proveedor: $e");
            return Proveedor(
              nombre: 'Desconocido',
              telefono: 'N/A',
              correo: 'N/A',
              direccion: 'N/A',
              rfc: 'N/A',
            );
          }
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error al obtener proveedores: $e");
      return [];
    }
  }

  List<Proveedor> filtrar(List<Proveedor> lista, String query) {
    return lista
        .where((p) => p.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
