import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'database_helper.dart';

Future<void> main() async {
  // Memastikan Flutter siap sebelum database diakses
  WidgetsFlutterBinding.ensureInitialized();

  // Membuka database lokal dan membuat tabel jika belum ada
  await DatabaseHelper.instance.database;

  // Menjalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker Final',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),

      // Halaman pertama adalah Login
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}