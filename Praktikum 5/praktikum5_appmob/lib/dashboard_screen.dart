import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final int userId;

  const DashboardScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Saldo awal sementara
  final int _initialBalance = 5000000;

  int _totalExpense = 0;
  List<Map<String, dynamic>> _transactions = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Mengambil transaksi dan total pengeluaran dari SQLite
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions =
          await DatabaseHelper.instance.getTransactions(
        widget.userId,
      );

      final totalExpense =
          await DatabaseHelper.instance.getTotalExpense(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _transactions = transactions;
        _totalExpense = totalExpense;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mengambil data transaksi.';
      });
    }
  }

  // Membuka halaman tambah transaksi
  Future<void> _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          userId: widget.userId,
        ),
      ),
    );

    // Memuat ulang data ketika kembali ke Dashboard
    if (mounted) {
      _loadData();
    }
  }

  // Format angka menjadi Rupiah
  String _formatRupiah(int amount) {
    final String number = amount.abs().toString();
    final StringBuffer result = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      result.write(number[i]);

      final int remaining = number.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        result.write('.');
      }
    }

    return 'Rp $result';
  }

  // Mengubah format tanggal database menjadi tanggal tampilan
  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  // Menentukan ikon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Makanan':
        return Icons.fastfood;

      case 'Transportasi':
        return Icons.directions_car;

      case 'Hiburan':
        return Icons.movie;

      default:
        return Icons.receipt_long;
    }
  }

  // Menentukan warna berdasarkan kategori
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Makanan':
        return Colors.orange;

      case 'Transportasi':
        return Colors.blue;

      case 'Hiburan':
        return Colors.purple;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentBalance =
        _initialBalance - _totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: _openAddTransaction,
        child: const Icon(Icons.add),
      ),

      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${widget.userName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _buildBalanceCard(currentBalance),

              const SizedBox(height: 20),

              // Ringkasan total pengeluaran
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.redAccent,
                        child: Icon(
                          Icons.trending_down,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Total Pengeluaran',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      Text(
                        _formatRupiah(_totalExpense),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Transaksi Terakhir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  // Kartu saldo utama
  Widget _buildBalanceCard(int balance) {
    return Card(
      elevation: 4,
      color: Colors.redAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saldo Utama',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _formatRupiah(balance),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Daftar transaksi yang diambil dari database
  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(_errorMessage!),

              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: Colors.grey,
                ),

                SizedBox(height: 12),

                Text(
                  'Belum ada transaksi.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Tekan tombol + untuk menambahkan transaksi.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Menampilkan maksimal 5 transaksi terbaru
    final latestTransactions =
        _transactions.take(5).toList();

    return Card(
      elevation: 2,
      child: Column(
        children: [
          for (int i = 0;
              i < latestTransactions.length;
              i++) ...[
            _buildTransactionItem(
              latestTransactions[i],
            ),

            if (i < latestTransactions.length - 1)
              const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  // Tampilan setiap transaksi
  Widget _buildTransactionItem(
    Map<String, dynamic> transaction,
  ) {
    final String title =
        transaction['title'] as String;

    final int amount =
        (transaction['amount'] as num).toInt();

    final String category =
        transaction['category'] as String;

    final String date =
        transaction['date'] as String;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getCategoryColor(category),
        child: Icon(
          _getCategoryIcon(category),
          color: Colors.white,
        ),
      ),

      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(
        '$category • ${_formatDate(date)}',
      ),

      trailing: Text(
        '- ${_formatRupiah(amount)}',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              title: title,
              amount: '- ${_formatRupiah(amount)}',
              category: category,
              date: _formatDate(date),
            ),
          ),
        );
      },
    );
  }
}