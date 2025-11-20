import 'package:flutter/foundation.dart';
import '../models/sale.dart';
import '../database/database_helper.dart';

class SaleProvider with ChangeNotifier {
  List<Sale> _sales = [];
  bool _isLoading = false;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sales = await DatabaseHelper.instance.getAllSales();
    } catch (e) {
      debugPrint('Error loading sales: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSale(Sale sale) async {
    try {
      await DatabaseHelper.instance.insertSale(sale);
      await loadSales();
    } catch (e) {
      debugPrint('Error adding sale: $e');
      rethrow;
    }
  }

  Future<void> deleteSale(int id) async {
    try {
      await DatabaseHelper.instance.deleteSale(id);
      await loadSales();
    } catch (e) {
      debugPrint('Error deleting sale: $e');
      rethrow;
    }
  }

  Future<List<Sale>> getSalesByProduct(int productId) async {
    try {
      return await DatabaseHelper.instance.getSalesByProduct(productId);
    } catch (e) {
      debugPrint('Error getting sales by product: $e');
      return [];
    }
  }
}
