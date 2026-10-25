import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.amber,
      ),
      body: ListView.builder(
        itemCount: 5, // Contoh 5 data riwayat
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.amber),
            title: Text('Transaksi ${index + 1}'),
            subtitle: const Text('24 Okt 2026'),
            trailing: const Text(
              '- Rp 50.000',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}