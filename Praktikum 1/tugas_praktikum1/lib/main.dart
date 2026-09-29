// 2411531004

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KalkulatorKabatakuApp());
}

class KalkulatorKabatakuApp extends StatelessWidget {
  const KalkulatorKabatakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator Kabataku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3949AB)),
        useMaterial3: true,
      ),
      home: const KalkulatorPage(),
    );
  }
}

class KalkulatorPage extends StatefulWidget {
  const KalkulatorPage({super.key});

  @override
  State<KalkulatorPage> createState() => _KalkulatorPageState();
}

class _KalkulatorPageState extends State<KalkulatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _angkaPertamaController = TextEditingController();
  final _angkaKeduaController = TextEditingController();

  String _hasil = '0';
  String _ekspresi = '';

  @override
  void dispose() {
    _angkaPertamaController.dispose();
    _angkaKeduaController.dispose();
    super.dispose();
  }

  String _formatAngka(double nilai) {
    if (nilai.isNaN) return 'Tidak terdefinisi';
    if (nilai == nilai.truncateToDouble()) return nilai.truncate().toString();
    var teks = nilai.toStringAsFixed(4);
    teks = teks.replaceFirst(RegExp(r'0+$'), '');
    return teks.replaceFirst(RegExp(r'\.$'), '');
  }

  String? _validasiAngka(String? value) {
    final teks = value?.trim() ?? '';
    if (teks.isEmpty) return 'Angka tidak boleh kosong';
    if (double.tryParse(teks) == null) return 'Masukkan angka yang valid';
    return null;
  }

  void _hitung(String operator) {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final angkaPertama = double.parse(_angkaPertamaController.text.trim());
    final angkaKedua = double.parse(_angkaKeduaController.text.trim());

    if (operator == '÷' && angkaKedua == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Pembagian dengan nol tidak terdefinisi'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      return;
    }

    final hasil = switch (operator) {
      '+' => angkaPertama + angkaKedua,
      '−' => angkaPertama - angkaKedua,
      '×' => angkaPertama * angkaKedua,
      _ => angkaPertama / angkaKedua,
    };

    setState(() {
      _ekspresi =
          '${_formatAngka(angkaPertama)} $operator ${_formatAngka(angkaKedua)}';
      _hasil = _formatAngka(hasil);
    });
  }

  void _hapus() {
    FocusScope.of(context).unfocus();
    _angkaPertamaController.clear();
    _angkaKeduaController.clear();
    setState(() {
      _hasil = '0';
      _ekspresi = '';
    });
  }

  InputDecoration _dekorasiInput(String label, IconData ikon) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(ikon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    );
  }

  Widget _tombolOperasi(String simbol, String nama, IconData ikon) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => _hitung(simbol),
        icon: Icon(ikon, size: 18),
        label: Text(nama),
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calculate_outlined),
            SizedBox(width: 8),
            Text('Kalkulator Kabataku'),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3949AB), Color(0xFF5C6BC0), Color(0xFF9FA8DA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(
                              Icons.calculate,
                              color: scheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ayo Hitung!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Masukkan dua angka lalu pilih operasinya',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _angkaPertamaController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[-.0-9]'),
                          ),
                        ],
                        textInputAction: TextInputAction.next,
                        validator: _validasiAngka,
                        decoration: _dekorasiInput(
                          'Angka Pertama',
                          Icons.looks_one_outlined,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _angkaKeduaController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[-.0-9]'),
                          ),
                        ],
                        textInputAction: TextInputAction.done,
                        validator: _validasiAngka,
                        decoration: _dekorasiInput(
                          'Angka Kedua',
                          Icons.looks_two_outlined,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'PILIH OPERASI KABATAKU',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _tombolOperasi('×', 'Kali', Icons.close),
                          const SizedBox(width: 12),
                          _tombolOperasi('÷', 'Bagi', Icons.percent),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _tombolOperasi('+', 'Tambah', Icons.add),
                          const SizedBox(width: 12),
                          _tombolOperasi('−', 'Kurang', Icons.remove),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'HASIL',
                              style: TextStyle(
                                color: Colors.indigo.shade100,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _hasil,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _ekspresi.isEmpty
                                  ? 'Masukkan angka untuk mulai menghitung'
                                  : _ekspresi,
                              style: TextStyle(
                                color: Colors.indigo.shade100,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _hapus,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Hapus'),
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
