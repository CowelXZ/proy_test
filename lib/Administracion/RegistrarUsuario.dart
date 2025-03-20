import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  final fechaController = TextEditingController();

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

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      confirmText: "Aceptar",
      cancelText: "Cancelar",
      helpText: "Seleccionar fecha",
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff14AE5C),
              onPrimary: Colors.white,
              surface: Color(0xFF022044),
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Color(0xff14AE5C)),
              ),
            ),
            dialogTheme: DialogTheme(backgroundColor: Color(0xFF022044)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> saveUser() async {
    final nombre = nombreController.text.trim();
    final apellidos = apellidosController.text.trim();
    final telefono = telefonoController.text.trim();
    final rfc = rfcController.text.trim();
    final usuario = usuarioController.text.trim();
    final contrasena = contrasenaController.text;
    final confirmarContrasena = confirmarContrasenaController.text;
    final cumpleanos = fechaController.text.trim();

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
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF022044), Color(0xFF01021E)],
          ),
        ),
        child: Column(
          children: [
            const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: Text(
                    'Nuevos Usuarios',
                    style: TextStyle(
                      color: Color(0xffF5F5F5),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 750,
                  height: 550, // Adjusted height to fit the form
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
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.white, size: 30),
                                  ),
                                  const Text(
                                    'Atras',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              const CircleAvatar(
                                radius: 25,
                                backgroundColor: Color(0xFF081C42),
                                child: Icon(Icons.account_circle_outlined,
                                    size: 50, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: textFields(
                                              'Nombre', nombreController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: textFields(
                                              'Teléfono', telefonoController,
                                              keyboardType:
                                                  TextInputType.phone)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: textFields('Contraseña',
                                              contrasenaController,
                                              obscureText: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: textFields('Apellidos',
                                              apellidosController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child:
                                              textFields('RFC', rfcController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                          child: textFields(
                                              'Confirmar Contraseña',
                                              confirmarContrasenaController,
                                              obscureText: true)),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: textFields(
                                              'Usuario', usuarioController)),
                                      const SizedBox(width: 30),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: departamento,
                                          items:
                                              departamentos.map((String value) {
                                            return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value));
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
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextField(
                                            mouseCursor:
                                                SystemMouseCursors.click,
                                            controller: fechaController,
                                            readOnly: true,
                                            onTap: _seleccionarFecha,
                                            decoration: const InputDecoration(
                                              hintText: 'Fecha de nacimiento',
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15),
                                              prefixIcon:
                                                  Icon(Icons.date_range),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(
                                                  left: 10,
                                                  bottom: 10,
                                                  top: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  /*ElevatedButton(
                                    onPressed: saveUser,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xff14AE5C),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 15)),
                                    child: const Text('Guardar Usuario',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),*/
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: SizedBox(
                          height: 40,
                          width: 250,
                          child: ElevatedButton(
                            onPressed: saveUser,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              backgroundColor: const Color(0xff14AE5C),
                            ),
                            child: const Text(
                              'Guardar Usuario',
                              style: TextStyle(color: Color(0xffF5F5F5)),
                            ),
                          ),
                        ),
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
