import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import '../providers/payment_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStatistics();
      context.read<ProductProvider>().loadProducts();
      context.read<SaleProvider>().loadSales();
      context.read<PaymentProvider>().loadPayments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Genel', icon: Icon(Icons.dashboard)),
            Tab(text: 'Ürünler', icon: Icon(Icons.inventory)),
            Tab(text: 'Hareketler', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GeneralReportTab(),
          _ProductsReportTab(),
          _TransactionsTab(),
        ],
      ),
    );
  }
}

// Genel Rapor Sekmesi
class _GeneralReportTab extends StatelessWidget {
  const _GeneralReportTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportCard(
                title: 'Toplam Satış Geliri',
                value: CurrencyFormatter.format(provider.totalRevenue),
                icon: Icons.shopping_cart,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _ReportCard(
                title: 'Benim Toplam Karım',
                value: CurrencyFormatter.format(provider.myProfit),
                icon: Icons.account_balance_wallet,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 2),
              const SizedBox(height: 12),
              _ReportCard(
                title: 'Komşuya Toplam Borç',
                value: CurrencyFormatter.format(provider.totalOwed),
                icon: Icons.account_balance,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _ReportCard(
                title: 'Komşuya Ödenen',
                value: CurrencyFormatter.format(provider.totalPaid),
                icon: Icons.payment,
                color: Colors.purple,
              ),
              const SizedBox(height: 12),
              _ReportCard(
                title: 'Kalan Borç',
                value: CurrencyFormatter.format(provider.remainingDebt),
                icon: Icons.warning,
                color: provider.remainingDebt > 0 ? Colors.red : Colors.green,
                isHighlight: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Ürünler Rapor Sekmesi
class _ProductsReportTab extends StatelessWidget {
  const _ProductsReportTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.products.isEmpty) {
          return const Center(
            child: Text('Henüz ürün bulunmuyor'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    product.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Stok: ${product.stockQuantity} adet'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow('Maliyet', CurrencyFormatter.format(product.costPrice)),
                        _InfoRow('Satış Fiyatı', CurrencyFormatter.format(product.salePrice)),
                        _InfoRow('Kâr Yüzdesi', '%${product.profitPercentage.toStringAsFixed(0)}'),
                        _InfoRow('Kâr Tutarı', CurrencyFormatter.format(product.totalProfit)),
                        const Divider(),
                        _InfoRow(
                          'Komşu Payı (satış başı)',
                          CurrencyFormatter.format(product.ownerShare),
                          color: Colors.orange,
                        ),
                        _InfoRow(
                          'Benim Payım (satış başı)',
                          CurrencyFormatter.format(product.myShare),
                          color: Colors.green,
                        ),
                        const Divider(),
                        _InfoRow('Eklenme Tarihi', DateFormatter.formatDate(product.createdAt)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Hareketler Sekmesi
class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.teal,
            tabs: [
              Tab(text: 'Satışlar'),
              Tab(text: 'Ödemeler'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SalesListView(),
                _PaymentsListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.sales.isEmpty) {
          return const Center(child: Text('Henüz satış bulunmuyor'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.sales.length,
          itemBuilder: (context, index) {
            final sale = provider.sales[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.shopping_cart, color: Colors.white),
                ),
                title: Text(sale.productName),
                subtitle: Text(
                  '${sale.quantity} adet × ${CurrencyFormatter.format(sale.salePrice)} = ${CurrencyFormatter.format(sale.salePrice * sale.quantity)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormatter.formatDate(sale.saleDate),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PaymentsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.payments.isEmpty) {
          return const Center(child: Text('Henüz ödeme bulunmuyor'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.payments.length,
          itemBuilder: (context, index) {
            final payment = provider.payments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.payment, color: Colors.white),
                ),
                title: Text(
                  CurrencyFormatter.format(payment.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: payment.note != null ? Text(payment.note!) : null,
                trailing: Text(
                  DateFormatter.formatDate(payment.paymentDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Yardımcı Widget'lar
class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isHighlight;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHighlight ? 8 : 4,
      child: Padding(
        padding: EdgeInsets.all(isHighlight ? 20 : 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: isHighlight ? 40 : 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isHighlight ? 16 : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isHighlight ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
