class Payment {
  final int? id;
  final double amount;
  final DateTime paymentDate;
  final String? note;

  Payment({
    this.id,
    required this.amount,
    required this.paymentDate,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'note': note,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      note: map['note'] as String?,
    );
  }

  Payment copyWith({
    int? id,
    double? amount,
    DateTime? paymentDate,
    String? note,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      note: note ?? this.note,
    );
  }
}
