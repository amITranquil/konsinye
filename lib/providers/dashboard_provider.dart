import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class DashboardProvider with ChangeNotifier {
  double _totalRevenue = 0.0;
  double _totalOwed = 0.0;
  double _totalPaid = 0.0;
  double _remainingDebt = 0.0;
  double _myProfit = 0.0;
  bool _isLoading = false;

  double get totalRevenue => _totalRevenue;
  double get totalOwed => _totalOwed;
  double get totalPaid => _totalPaid;
  double get remainingDebt => _remainingDebt;
  double get myProfit => _myProfit;
  bool get isLoading => _isLoading;

  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalRevenue = await DatabaseHelper.instance.getTotalSalesRevenue();
      _totalOwed = await DatabaseHelper.instance.getTotalOwnerShareFromSales();
      _totalPaid = await DatabaseHelper.instance.getTotalPaymentsToOwner();
      _remainingDebt = await DatabaseHelper.instance.getRemainingDebtToOwner();
      _myProfit = await DatabaseHelper.instance.getTotalMyProfit();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
