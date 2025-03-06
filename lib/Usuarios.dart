import 'package:flutter/material.dart';
import 'package:proy_test/RegistrarUsuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const Usuarios());
}

class Usuarios extends StatelessWidget {
  const Usuarios({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListaUsuarios(),
      ),
    );
  }
}

class ListaUsuarios extends StatefulWidget {
  const ListaUsuarios({super.key});

  @override
  _ListaUsuariosState createState() => _ListaUsuariosState();
}

class _ListaUsuariosState extends State<ListaUsuarios> {
  final TextEditingController buscadorController = TextEditingController();
  String dropdownValue = 'Departamento';
  List<dynamic> usuarios = [];

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  Future<void> fetchUsuarios() async {
    final url = Uri.parse(
        'http://localhost:3000/getUsers'); // Reemplaza con tu URL real

    try {
      final response = await http.get(url);

      print("Código de respuesta: ${response.statusCode}");
      print("Cuerpo de respuesta: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          usuarios =
              data; // Asegúrate de que `usuarios` es una lista en tu clase
        });
      } else {
        throw Exception("Error al cargar los usuarios: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción atrapada: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Usuarios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(color: Colors.grey),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const <DataColumn>[
                    DataColumn(label: Text('NOMBRE COMPLETO')),
                    DataColumn(label: Text('DEPARTAMENTO')),
                    DataColumn(label: Text('TELÉFONO')),
                    DataColumn(label: Text('USUARIO')),
                    DataColumn(label: Text('CUMPLEAÑOS')),
                    DataColumn(label: Text('FECHA REGISTRO')),
                    DataColumn(label: Text('RFC')),
                    DataColumn(label: Text('OPCIONES')),
                  ],
                  // Dentro de tu código donde mapeas los usuarios
                  rows: usuarios.map<DataRow>((usuario) {
                    // Convertir la fecha en formato adecuado
                    String formattedDate = '';
                    if (usuario['cumpleanos'] != null) {
                      DateTime cumpleanosDate =
                          DateTime.parse(usuario['cumpleanos']);
                      formattedDate = DateFormat('yyyy-MM-dd')
                          .format(cumpleanosDate); // Formato 'AAAA-MM-DD'
                    }

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(usuario['nombre'] ?? 'No disponible')),
                        DataCell(
                            Text(usuario['departamento'] ?? 'No disponible')),
                        DataCell(Text(usuario['telefono'] ?? 'No disponible')),
                        DataCell(Text(usuario['usuario'] ?? 'No disponible')),
                        DataCell(
                            Text(formattedDate)), // Usamos la fecha formateada
                        DataCell(
                            Text(usuario['fecha_registro'] ?? 'No disponible')),
                        DataCell(Text(usuario['rfc'] ?? 'No disponible')),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistroU(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff14AE5C),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add_alt_1_sharp,
                          color: Color(0xffF5F5F5), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Nuevo Usuario',
                        style:
                            TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
