import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../database/database_helper.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _payments = await DatabaseHelper.instance.getAllPayments();
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPayment(Payment payment) async {
    try {
      await DatabaseHelper.instance.insertPayment(payment);
      await loadPayments();
    } catch (e) {
      debugPrint('Error adding payment: $e');
      rethrow;
    }
  }

  Future<void> deletePayment(int id) async {
    try {
      await DatabaseHelper.instance.deletePayment(id);
      await loadPayments();
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      rethrow;
    }
  }
}
