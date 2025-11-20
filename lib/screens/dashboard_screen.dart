import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/currency_formatter.dart';
import 'products_screen.dart';
import 'sales_screen.dart';
import 'payments_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsinye Takip Sistemi'),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode ? 'Açık Tema' : 'Koyu Tema',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardProvider>().loadStatistics();
            },
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Özet Kartlar
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Toplam Satış',
                        amount: provider.totalRevenue,
                        icon: Icons.shopping_cart,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Benim Kârım',
                        amount: provider.myProfit,
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Toplam Borç',
                        amount: provider.totalOwed,
                        icon: Icons.account_balance,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Ödenen',
                        amount: provider.totalPaid,
                        icon: Icons.payment,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SummaryCard(
                  title: 'Kalan Borç',
                  amount: provider.remainingDebt,
                  icon: Icons.warning,
                  color: Colors.red,
                  isLarge: true,
                ),
                const SizedBox(height: 32),
                // Hızlı Erişim Butonları
                const Text(
                  'Hızlı Erişim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _QuickAccessButton(
                      title: 'Ürünler',
                      icon: Icons.inventory,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductsScreen(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<DashboardProvider>().loadStatistics();
                          }
                        });
                      },
                    ),
                    _QuickAccessButton(
                      title: 'Satış Yap',
                      icon: Icons.point_of_sale,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesScreen(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<DashboardProvider>().loadStatistics();
                          }
                        });
                      },
                    ),
                    _QuickAccessButton(
                      title: 'Ödeme Yap',
                      icon: Icons.account_balance_wallet,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PaymentsScreen(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<DashboardProvider>().loadStatistics();
                          }
                        });
                      },
                    ),
                    _QuickAccessButton(
                      title: 'Raporlar',
                      icon: Icons.assessment,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isLarge ? 32 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isLarge ? 18 : 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: isLarge ? 28 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
