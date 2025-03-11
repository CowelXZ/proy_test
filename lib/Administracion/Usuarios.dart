import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proy_test/Administracion/RegistrarUsuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<dynamic> usuarios = [];
  List<dynamic> usuariosFiltrados = [];
  String dropdownValue = 'Departamento';

  @override
  void initState() {
    super.initState();
    fetchUsuarios();
  }

  void _confirmarEliminacion(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Estás seguro?"),
          content: const Text(
              "Esta acción eliminará el usuario de manera permanente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin hacer nada
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                _eliminarUsuario(userId);
              },
              child:
                  const Text("Eliminar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarUsuario(int userId) async {
    final url = Uri.parse('http://localhost:3000/deleteUser/$userId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          usuarios.removeWhere((usuario) => usuario['id'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado exitosamente')),
        );
      } else {
        print("Error al eliminar usuario: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción atrapada: $e");
    }
  }

  Future<void> fetchUsuarios() async {
    final url =
        Uri.parse('http://localhost:3000/getUsers?orderBy=$dropdownValue');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          usuarios = json.decode(response.body);
          usuariosFiltrados = usuarios; // Inicializa con todos los usuarios
        });
      } else {
        print("Error al cargar los usuarios: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción atrapada: $e");
    }
  }

  void filtrarUsuarios(String query) {
    setState(() {
      if (query.isEmpty) {
        usuariosFiltrados = usuarios;
      } else {
        usuariosFiltrados = usuarios.where((usuario) {
          final nombre = usuario['nombre']?.toString().toLowerCase() ?? '';
          return nombre.contains(query.toLowerCase());
        }).toList();
      }
    });
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: buscadorController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged:
                            filtrarUsuarios, // 🔥 Llamamos a la función de filtrado
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Filtrar por:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        dropdownColor: const Color(0xFF022044),
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(height: 2, color: Colors.white),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                            fetchUsuarios();
                          }
                        },
                        items: ['Departamento', 'Cumpleaños', 'Fecha Registro']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF0665A4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset(
                        'images/PICNITO LOGO.jpeg',
                        fit: BoxFit.contain,
                      ),
                    ),
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
                  columns: const [
                    DataColumn(label: Text('NOMBRE COMPLETO')),
                    DataColumn(label: Text('DEPARTAMENTO')),
                    DataColumn(label: Text('TELÉFONO')),
                    DataColumn(label: Text('USUARIO')),
                    DataColumn(label: Text('CUMPLEAÑOS')),
                    DataColumn(label: Text('FECHA REGISTRO')),
                    DataColumn(label: Text('RFC')),
                    DataColumn(label: Text('OPCIONES')),
                  ],
                  rows: usuariosFiltrados.map<DataRow>((usuario) {
                    String formattedDate = usuario['cumpleanos'] != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(usuario['cumpleanos']))
                        : 'No disponible';

                    return DataRow(cells: [
                      DataCell(Text(usuario['nombre'] ?? 'No disponible')),
                      DataCell(
                          Text(usuario['departamento'] ?? 'No disponible')),
                      DataCell(Text(usuario['telefono'] ?? 'No disponible')),
                      DataCell(Text(usuario['usuario'] ?? 'No disponible')),
                      DataCell(Text(formattedDate)),
                      DataCell(
                          Text(usuario['fecha_registro'] ?? 'No disponible')),
                      DataCell(Text(usuario['rfc'] ?? 'No disponible')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () {}),
                            IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              onPressed: () =>
                                  _confirmarEliminacion(usuario['id']),
                            ),
                          ],
                        ),
                      ),
                    ]);
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
                    ).then((value) {
                      setState(() {
                        fetchUsuarios();
                      });
                    });
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
                      Text('Nuevo Usuario',
                          style: TextStyle(
                              color: Color(0xffF5F5F5), fontSize: 14)),
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
