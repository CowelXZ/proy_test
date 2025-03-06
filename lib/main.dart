import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper.connect();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQL Server',
      home: Scaffold(
        appBar: AppBar(title: Text('Conexión Flutter-SQL Server')),
        body: Center(child: Text('Revisar consola para estado de conexión')),
      ),
    );
  }
}
