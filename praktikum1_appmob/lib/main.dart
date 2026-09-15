import 'package:flutter/material.dart';
import 'form-textformfield.dart'; // Menghubungkan ke file form-textfield.dart

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Basic Form'),
        ),
        body: const MyFormText(),
      ),
    );
  }
}