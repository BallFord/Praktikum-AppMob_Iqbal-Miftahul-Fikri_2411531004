import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // GlobalKey untuk mengontrol form dan memicu validasi
  final _formKey = GlobalKey<FormState>();

  // Controller untuk mengambil teks dari input
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  // 1. Latihan: Controller khusus untuk menyimpan input tanggal
  final _dateController = TextEditingController(); 

  // State untuk Dropdown
  String _selectedCategory = 'Makanan';
  final List<String> _categories = ['Makanan', 'Transportasi', 'Hiburan', 'Lainnya'];

  // 2. Latihan: Fungsi untuk menampilkan DatePicker 
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Tanggal default saat dibuka
      firstDate: DateTime(2000),   // Batas awal tahun
      lastDate: DateTime(2100),    // Batas akhir tahun
    );

    if (pickedDate != null) {
      setState(() {
        // Mengubah format menjadi DD/MM/YYYY
        String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
        _dateController.text = formattedDate; // Memasukkan nilai ke TextFormField
      });
    }
  }

  @override
  void dispose() {
    // Bersihkan semua controller saat halaman ditutup
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose(); // Hapus controller tanggal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catat Transaksi Baru"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input 1: Judul Transaksi
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Judul Transaksi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Judul transaksi tidak boleh kosong";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input 2: Nominal Saldo (Keyboard Angka)
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Nominal (Rp)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nominal wajib diisi";
                  }
                  if (int.tryParse(value) == null) {
                    return "Harus berupa angka bulat yang valid";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Input 3: Kategori Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Kategori",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // 3. Latihan: Input 4 (Tanggal Transaksi) diletakkan sebelum tombol simpan
              TextFormField(
                controller: _dateController,
                readOnly: true, // Dibuat read-only agar user harus pakai DatePicker
                onTap: () => _selectDate(context), // Panggil DatePicker saat field ditekan
                decoration: const InputDecoration(
                  labelText: "Tanggal Transaksi (DD/MM/YYYY)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Tanggal wajib diisi"; // Validasi wajib diisi
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tersimpan: ${_titleController.text} (Rp ${_amountController.text}) pada ${_dateController.text}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Simpan Transaksi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}