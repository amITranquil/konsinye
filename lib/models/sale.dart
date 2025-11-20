class Sale {
  final int? id;
  final int productId;
  final String productName; // Ürün adını saklamak için
  final int quantity;
  final double costPrice; // Maliyet fiyatı
  final double salePrice;
  final DateTime saleDate;
  final double profitAmount;
  final double ownerShare;
  final double myShare;

  Sale({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.costPrice,
    required this.salePrice,
    required this.saleDate,
    required this.profitAmount,
    required this.ownerShare,
    required this.myShare,
  });

  // Komşuya bu satıştan ödenecek tutar (maliyet + komşu kâr payı)
  double get amountOwedToOwner => costPrice + ownerShare;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'sale_date': saleDate.toIso8601String(),
      'profit_amount': profitAmount,
      'owner_share': ownerShare,
      'my_share': myShare,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      costPrice: map['cost_price'] as double,
      salePrice: map['sale_price'] as double,
      saleDate: DateTime.parse(map['sale_date'] as String),
      profitAmount: map['profit_amount'] as double,
      ownerShare: map['owner_share'] as double,
      myShare: map['my_share'] as double,
    );
  }

  Sale copyWith({
    int? id,
    int? productId,
    String? productName,
    int? quantity,
    double? costPrice,
    double? salePrice,
    DateTime? saleDate,
    double? profitAmount,
    double? ownerShare,
    double? myShare,
  }) {
    return Sale(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      saleDate: saleDate ?? this.saleDate,
      profitAmount: profitAmount ?? this.profitAmount,
      ownerShare: ownerShare ?? this.ownerShare,
      myShare: myShare ?? this.myShare,
    );
  }
}
