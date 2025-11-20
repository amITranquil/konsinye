import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadSales();
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satışlar'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SaleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.point_of_sale, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz satış yapılmamış',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.sales.length,
            itemBuilder: (context, index) {
              final sale = provider.sales[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text(
                    sale.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Adet: ${sale.quantity}'),
                      Text('Maliyet: ${CurrencyFormatter.format(sale.costPrice)}'),
                      Text('Satış Fiyatı: ${CurrencyFormatter.format(sale.salePrice)}'),
                      Text('Toplam Gelir: ${CurrencyFormatter.format(sale.salePrice * sale.quantity)}'),
                      Text('Kâr: ${CurrencyFormatter.format(sale.profitAmount * sale.quantity)}'),
                      const Divider(),
                      Text(
                        'Komşuya Ödenecek: ${CurrencyFormatter.format(sale.amountOwedToOwner * sale.quantity)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      Text(
                        'Benim Kazancım: ${CurrencyFormatter.format(sale.myShare * sale.quantity)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const Divider(),
                      Text('Tarih: ${DateFormatter.formatDateTime(sale.saleDate)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, sale);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSaleDialog(context);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showSaleDialog(BuildContext context) {
    Product? selectedProduct;
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final products = context.watch<ProductProvider>().products;

          if (products.isEmpty) {
            return AlertDialog(
              title: const Text('Uyarı'),
              content: const Text('Satış yapabilmek için önce ürün eklemelisiniz.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tamam'),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text('Yeni Satış'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedProduct?.id,
                    decoration: const InputDecoration(
                      labelText: 'Ürün Seçin',
                      border: OutlineInputBorder(),
                    ),
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product.id,
                        child: Text('${product.name} (Stok: ${product.stockQuantity})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedProduct = products.firstWhere((p) => p.id == value);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Adet',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  if (selectedProduct != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Satış Detayları',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Maliyet: ${CurrencyFormatter.format(selectedProduct!.costPrice)}'),
                          Text('Satış Fiyatı: ${CurrencyFormatter.format(selectedProduct!.salePrice)}'),
                          Text('Kâr: ${CurrencyFormatter.format(selectedProduct!.totalProfit)}'),
                          const Divider(),
                          Text(
                            'Komşu Payı: ${CurrencyFormatter.format(selectedProduct!.ownerShare)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.orange[300]
                                  : Colors.orange,
                            ),
                          ),
                          Text(
                            'Benim Payım: ${CurrencyFormatter.format(selectedProduct!.myShare)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.green[300]
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedProduct == null || quantityController.text.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
                      );
                    }
                    return;
                  }

                  final quantity = int.parse(quantityController.text);

                  if (quantity <= 0) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adet 0\'dan büyük olmalıdır')),
                      );
                    }
                    return;
                  }

                  if (quantity > selectedProduct!.stockQuantity) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yetersiz stok')),
                      );
                    }
                    return;
                  }

                  final sale = Sale(
                    productId: selectedProduct!.id!,
                    productName: selectedProduct!.name,
                    quantity: quantity,
                    costPrice: selectedProduct!.costPrice,
                    salePrice: selectedProduct!.salePrice,
                    saleDate: DateTime.now(),
                    profitAmount: selectedProduct!.totalProfit,
                    ownerShare: selectedProduct!.ownerShare,
                    myShare: selectedProduct!.myShare,
                  );

                  try {
                    final saleProvider = context.read<SaleProvider>();
                    final productProvider = context.read<ProductProvider>();

                    await saleProvider.addSale(sale);

                    // Stok güncelle
                    final newStock = selectedProduct!.stockQuantity - quantity;
                    await productProvider.updateStock(
                      selectedProduct!.id!,
                      newStock,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Satış kaydedildi')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hata: $e')),
                      );
                    }
                  }
                },
                child: const Text('Satışı Kaydet'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Satışı Sil'),
        content: Text('${sale.productName} satışını silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final saleProvider = context.read<SaleProvider>();
                final productProvider = context.read<ProductProvider>();

                await saleProvider.deleteSale(sale.id!);

                // Stok geri ekle
                final product = productProvider.getProductById(sale.productId);
                if (product != null) {
                  final newStock = product.stockQuantity + sale.quantity;
                  await productProvider.updateStock(
                    sale.productId,
                    newStock,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Satış silindi ve stok geri eklendi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
