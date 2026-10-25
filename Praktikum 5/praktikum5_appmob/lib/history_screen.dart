import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'transaction_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  final int userId;

  const HistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _transactions = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // Mengambil seluruh transaksi pengguna dari SQLite
  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data =
          await DatabaseHelper.instance.getTransactions(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat riwayat transaksi.';
      });
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

  // Format tanggal transaksi
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

  // Ikon berdasarkan kategori
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

  // Warna berdasarkan kategori
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

  // Membuka detail transaksi
  void _openTransactionDetail(
    Map<String, dynamic> transaction,
  ) {
    final String title = transaction['title'] as String;
    final int amount =
        (transaction['amount'] as num).toInt();
    final String category =
        transaction['category'] as String;
    final String date = transaction['date'] as String;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadTransactions,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Icon(
              Icons.history,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Belum ada riwayat transaksi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Transaksi yang kamu simpan akan muncul di sini.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final transaction = _transactions[index];

          final String title =
              transaction['title'] as String;

          final int amount =
              (transaction['amount'] as num).toInt();

          final String category =
              transaction['category'] as String;

          final String date =
              transaction['date'] as String;

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    _getCategoryColor(category),
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
                _openTransactionDetail(transaction);
              },
            ),
          );
        },
      ),
    );
  }
}