import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proy_test/Vistas/RegistroIntermedios.dart';
import '';

class ListaIntermedios extends StatefulWidget {
  const ListaIntermedios({super.key});

  @override
  State<ListaIntermedios> createState() => _ListaIntermediosState();
}

class _ListaIntermediosState extends State<ListaIntermedios> {
  late Future<List<Intermedio>> _intermedios;

  Future<List<Intermedio>> fetchIntermedios() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getIntermedios'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Intermedio.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar intermedios');
    }
  }

  @override
  void initState() {
    super.initState();
    _intermedios = fetchIntermedios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff01021E),
      appBar: AppBar(
        title: const Text('Intermedios Registrados'),
        backgroundColor: const Color(0xff022044),
      ),
      body: FutureBuilder<List<Intermedio>>(
        future: _intermedios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay intermedios'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final i = items[index];
              return Card(
                color: const Color(0xff081C42),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: i.imagen != null
                      ? Image.network(i.imagen!, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                  title: Text(i.nombre, style: const TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${i.cantidadProducida} ${i.unidad}', style: const TextStyle(color: Colors.white70)),
                      Text('Costo: \$${i.costoTotalEstimado}', style: const TextStyle(color: Colors.white70)),
                      Text('Consumibles: ${i.consumibles.map((c) => "${c.nombre} (${c.cantidadUsada})").join(", ")}',
                        style: const TextStyle(color: Colors.white60),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
