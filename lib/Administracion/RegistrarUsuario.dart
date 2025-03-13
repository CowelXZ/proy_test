import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistroU extends StatefulWidget {
  const RegistroU({super.key});

  @override
  _RegistroUState createState() => _RegistroUState();
}

class _RegistroUState extends State<RegistroU> {
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final telefonoController = TextEditingController();
  final rfcController = TextEditingController();
  final usuarioController = TextEditingController();
  final contrasenaController = TextEditingController();
  final confirmarContrasenaController = TextEditingController();
  final cumpleanosController = TextEditingController();

  String departamento = 'Taquilla';
  final List<String> departamentos = [
    'Taquilla',
    'Dulceria',
    'Cafeteria',
    'Limpieza'
  ];

  void _mostrarMensaje(String mensaje, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> saveUser() async {
    final nombre = nombreController.text.trim();
    final apellidos = apellidosController.text.trim();
    final telefono = telefonoController.text.trim();
    final rfc = rfcController.text.trim();
    final usuario = usuarioController.text.trim();
    final contrasena = contrasenaController.text;
    final confirmarContrasena = confirmarContrasenaController.text;
    final cumpleanos = cumpleanosController.text.trim();

    if ([nombre, apellidos, telefono, rfc, usuario, contrasena, cumpleanos]
        .any((element) => element.isEmpty)) {
      _mostrarMensaje("Todos los campos son obligatorios.");
      return;
    }

    final RegExp regexTelefono = RegExp(r'^[0-9]+$'); // Solo números
    if (!regexTelefono.hasMatch(telefono)) {
      _mostrarMensaje("El teléfono solo debe contener números.");
      return;
    }

    final RegExp regexRFC =
        RegExp(r'^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$'); // Formato RFC
    if (!regexRFC.hasMatch(rfc)) {
      _mostrarMensaje("El RFC no tiene un formato válido.");
      return;
    }

    if (contrasena.length < 6) {
      _mostrarMensaje("La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    if (contrasena != confirmarContrasena) {
      _mostrarMensaje("Las contraseñas no coinciden. Intenta de nuevo.",
          color: Colors.orange);
      confirmarContrasenaController.clear();
      return;
    }

    try {
      DateTime.parse(cumpleanos);
    } catch (e) {
      _mostrarMensaje("Formato de fecha inválido. Usa YYYY-MM-DD.");
      return;
    }

    final Map<String, String> userData = {
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'rfc': rfc,
      'usuario': usuario,
      'contrasena': contrasena,
      'cumpleanos': cumpleanos,
      'departamento': departamento,
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/addUser'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        _mostrarMensaje("Usuario guardado con éxito", color: Colors.green);
        await Future.delayed(
            const Duration(seconds: 2)); // Espera a que se vea el mensaje
        if (mounted)
          Navigator.pop(context); // Cierra la ventana solo si sigue abierta
      } else {
        _mostrarMensaje("Error al guardar usuario: ${response.body}");
      }
    } catch (error) {
      _mostrarMensaje("Error de conexión: $error");
    }
  }

  Widget textFields(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      style: const TextStyle(color: Colors.black),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: label,
        floatingLabelStyle: const TextStyle(
            color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15),
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF022044), Color(0xFF01021E)]),
        ),
        child: Row(
          children: [
            Container(
              width: 180,
              margin: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF081C42),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.asset('images/PICNITO LOGO.jpeg',
                          fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 30),
                        ),
                        const Text('Nuevo Usuario',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Color(0xFF081C42),
                          child: Icon(Icons.account_circle_outlined,
                              size: 50, color: Colors.white),
                        ),
                      ],
                    ), //saveUser
                    const SizedBox(height: 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child:
                                        textFields('Nombre', nombreController)),
                                const SizedBox(width: 30),
                                Expanded(
                                    child: textFields(
                                        'Teléfono', telefonoController,
                                        keyboardType: TextInputType.phone)),
                                const SizedBox(width: 30),
                                Expanded(
                                    child: textFields(
                                        'Contraseña', contrasenaController,
                                        obscureText: true)),
                              ],
                            ),
                            const SizedBox(height: 60),
                            Row(
                              children: [
                                Expanded(
                                    child: textFields(
                                        'Apellidos', apellidosController)),
                                const SizedBox(width: 30),
                                Expanded(
                                    child: textFields('RFC', rfcController)),
                                const SizedBox(width: 30),
                                Expanded(
                                    child: textFields('Confirmar Contraseña',
                                        confirmarContrasenaController,
                                        obscureText: true)),
                              ],
                            ),
                            const SizedBox(height: 60),
                            Row(
                              children: [
                                Expanded(
                                    child: textFields(
                                        'Usuario', usuarioController)),
                                const SizedBox(width: 30),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: departamento,
                                    items: departamentos.map((String value) {
                                      return DropdownMenuItem<String>(
                                          value: value, child: Text(value));
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          departamento = newValue;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      labelText: 'Departamento',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Expanded(
                                    child: textFields('Cumpleaños (YYYY-MM-DD)',
                                        cumpleanosController,
                                        keyboardType: TextInputType.datetime)),
                              ],
                            ),
                            const SizedBox(height: 60),
                            ElevatedButton(
                              onPressed: saveUser,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff14AE5C),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15)),
                              child: const Text('Guardar Usuario',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
