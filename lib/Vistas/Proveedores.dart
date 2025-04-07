import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:proy_test/Vistas/Menu.dart';
import 'package:proy_test/Vistas/RegistroProovedores.dart';
import 'package:proy_test/Models/proovedor_model.dart';
import 'package:proy_test/Controladores/proovedor_controller.dart';

void main() {
  runApp(const Proveedores());
}

class Proveedores extends StatelessWidget {
  const Proveedores({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListaProveedores(),
      ),
    );
  }
}

class ListaProveedores extends StatefulWidget {
  const ListaProveedores({super.key});

  @override
  _ListaProveedoresState createState() => _ListaProveedoresState();
}

class _ListaProveedoresState extends State<ListaProveedores> {
  final TextEditingController buscadorController = TextEditingController();
  late ProveedorController proveedorController;

  List<Proveedor> proveedores = [];
  List<Proveedor> proveedoresFiltrados = [];

  @override
  void initState() {
    super.initState();
    proveedorController = ProveedorController(context);
    cargarProveedores();
  }

  Future<void> cargarProveedores() async {
    proveedores = (await proveedorController.fetchProveedores()).cast<Proveedor>();
    setState(() {
      proveedoresFiltrados = proveedores;
    });
  }

  void filtrarProveedores(String query) {
    setState(() {
      proveedoresFiltrados = proveedorController.filtrar(proveedores, query);
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Menu()),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Proveedores',
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
                          hintText: 'Buscar por Nombre...',
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
                        onChanged: filtrarProveedores,
                      ),
                    ),
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
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Teléfono')),
                    DataColumn(label: Text('Correo')),
                    DataColumn(label: Text('Dirección')),
                    DataColumn(label: Text('RFC')),
                    DataColumn(label: Text('Opciones')),
                  ],
                  rows: proveedoresFiltrados.map((p) {
                    return DataRow(cells: [
                      DataCell(Text(p.nombre)),
                      DataCell(Text(p.telefono)),
                      DataCell(Text(p.correo)),
                      DataCell(Text(p.direccion)),
                      DataCell(Text(p.rfc)),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroProveedoresView(),
                        ),
                      ).then((_) => cargarProveedores());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff14AE5C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(EvaIcons.peopleOutline,
                            color: Color(0xffF5F5F5), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Nuevo Proveedor',
                          style:
                              TextStyle(color: Color(0xffF5F5F5), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
