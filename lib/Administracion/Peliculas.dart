import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const listaPeliculas());
}

class listaPeliculas extends StatelessWidget {
  const listaPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Peliculas(),
      ),
    );
  }
}

//build
class Peliculas extends StatefulWidget {
  const Peliculas({super.key});
  @override
  _PeliculasState createState() => _PeliculasState();
}

class _PeliculasState extends State<Peliculas> {
  List<dynamic> peliculas = [];
  List<dynamic> peliculasFiltradas = []; // Tarjeta

  @override
  void initState() {
    super.initState();
    fetchMovies(); // Llama a la función para cargar las películas al iniciar
  }

  Future<void> fetchMovies() async {
    final url = Uri.parse('http://localhost:3000/getMovies');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          peliculas = json.decode(response.body);
          peliculasFiltradas = peliculas; // Inicializa la lista filtrada
        });
      } else {
        print("Error al cargar las películas: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción atrapada: $e");
    }
  }

  final TextEditingController buscadorController = TextEditingController();
  final String titulo = 'Jurassic Park';
  final String genero = 'Acción';
  final String idiomas = 'Español, Inglés';

  Widget TarjetaPelicula(Map<String, dynamic> pelicula) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10, top: 10, right: 80, left: 10),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                image: pelicula['poster'] != null
                    ? DecorationImage(
                        image: NetworkImage(
                            pelicula['poster']), // Cargar imagen desde URL
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
                        image: AssetImage(
                            'images/Poster JWR.jpeg'), // Imagen por defecto
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pelicula['titulo'] ?? 'Título desconocido',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  'Género: ${pelicula['genero'] ?? 'Desconocido'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  'Idiomas: ${pelicula['idiomas'] ?? 'Desconocido'}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          side:
                              const BorderSide(color: Colors.black, width: 1)),
                      onPressed: () {},
                      child: const Text('Editar',
                          style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 2,
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                      onPressed: () {},
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF022044), Color(0xFF01021E)],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Atras',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                              controller: buscadorController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar por titulo...',
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  peliculasFiltradas = peliculas
                                      .where((pelicula) => pelicula['titulo']
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                      .toList();
                                });
                              },
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
                  Center(
                    child: Stack(
                      children: [//TarjetaPelicula
                        Container(
                          width: 900,
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
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const Text(
                                  textAlign: TextAlign.center,
                                  'Peliculas',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...peliculasFiltradas
                                    .map((p) => TarjetaPelicula(p))
                                    .toList(),
                              ],
                            ),
                          ),
                        ), //TextField
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: FloatingActionButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 2,
                              backgroundColor: const Color(0xff2365AD),
                              onPressed: () {},
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 35)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
