/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:proy_test/Vistas/Administracion/InicioSesion.dart';
import 'Funciones.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AFunciones extends StatelessWidget {
  const AFunciones({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Funciones(),
      ),
    );
  }
}

class Funciones extends StatefulWidget {
  const Funciones({super.key});

  @override
  _FuncionesState createState() => _FuncionesState();
}

class _FuncionesState extends State<Funciones> {
  List<Map<String, dynamic>> peliculas = [];

  @override
  void initState() {
    super.initState();
    fetchPeliculas();
  }

  String query = '';

  final tituloController = TextEditingController();
  final horarioController = TextEditingController();
  final salaController = TextEditingController();
  final fechaController = TextEditingController();
  final tipoController = TextEditingController();
  final idiomaController = TextEditingController();
  final buscadorController = TextEditingController();
  File? _imagen;
  String dropdownValue = 'Tradicional';
  String dropdownValue2 = '1';
  String dropdownValue3 = 'Español';

  Future<void> _seleccionarHorario() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        horarioController.text = '${picked.hour}h ${picked.minute}m';
      });
    }
  }

  Future<void> fetchPeliculas() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/getMovies'));
      if (response.statusCode == 200) {
        setState(() {
          peliculas =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      }
    } catch (e) {
      print("Error al cargar películas: $e");
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  void buscarPeliculas(String query) {
  setState(() {
    _resultadosBusqueda = peliculasDisponibles
        .where((pelicula) => pelicula['titulo']
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ), //Pelicula
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 750,
              height: 550,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff081C42),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back,
                                color: Color.fromARGB(255, 255, 255, 255),
                                size: 30),
                          ),
                          const Text(
                            'Atras',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: buscadorController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar Pelicula',
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
                            onChanged: (value) {
  buscarPeliculas(value);
},);
                            },
                          ),
                        ),
                      ),
                      if (query.isNotEmpty)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView(
                            children: peliculas
                                .where((p) =>
                                    p['Titulo'].toLowerCase().contains(query))
                                .map((p) => ListTile(
                                      title: Text(
                                        p['Titulo'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          tituloController.text = p['Titulo'];
                                          buscadorController.text = '';
                                          query = '';
                                          // Si manejas poster también:
                                          // posterUrl = p['Poster'];
                                        });
                                      },
                                    ))
                                .toList(),
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
                  const SizedBox(height: 75),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Poster',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            _imagen == null
                                ? Container(
                                    width: 150,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image,
                                        size: 100, color: Colors.grey),
                                  )
                                : Image.file(
                                    _imagen!,
                                    width: 150,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Titulo',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: tituloController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Asigne un horario',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: horarioController,
                                readOnly: true,
                                onTap: _seleccionarHorario,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione un horario',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  prefixIcon: Icon(Icons.access_time),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tipo de Sala',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(
                                  color: Colors.transparent,
                                ),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                iconSize: 24,
                                //elevation: 16,
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Tradicional',
                                  '3D',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seleccione una Sala',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(
                                  color: Colors.transparent,
                                ),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue2,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                iconSize: 24,
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue2 = newValue!;
                                  });
                                },
                                items: <String>[
                                  '1',
                                  '2',
                                  '3',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Asigne una Fecha',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextField(
                                controller: fechaController,
                                readOnly: true,
                                onTap: _seleccionarFecha,
                                decoration: const InputDecoration(
                                  hintText: 'Seleccione una fecha',
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  prefixIcon: Icon(Icons.date_range),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.only(left: 10, bottom: 10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Seleccione Idioma',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              width: 200,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: DropdownButton<String>(
                                underline: Container(
                                  color: Colors.transparent,
                                ),
                                dropdownColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                value: dropdownValue3,
                                icon: const Icon(Icons.arrow_drop_down,
                                    color: Colors.black),
                                iconSize: 24,
                                //elevation: 16,
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue3 = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Español',
                                  'Ingles',
                                  'Frances',
                                  'Japon',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 40,
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    backgroundColor: const Color(0xff14AE5C)),
                                child: const Text(
                                  'Guardar Funcion',
                                  style: TextStyle(color: Color(0xffF5F5F5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
