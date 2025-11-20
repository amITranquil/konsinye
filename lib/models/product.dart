class Product {
  final int? id;
  final String name;
  final double costPrice;
  final double profitPercentage;
  final int stockQuantity;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.costPrice,
    required this.profitPercentage,
    required this.stockQuantity,
    required this.createdAt,
  });

  // Satış fiyatını hesapla
  double get salePrice => costPrice * (1 + profitPercentage / 100);

  // Toplam karı hesapla
  double get totalProfit => salePrice - costPrice;

  // Komşu payını hesapla (kar / 2)
  double get ownerShare => totalProfit / 2;

  // Benim payımı hesapla (kar / 2)
  double get myShare => totalProfit / 2;

  // Komşuya ödenecek toplam tutar (maliyet + komşu payı)
  double get amountToPayOwner => costPrice + ownerShare;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost_price': costPrice,
      'profit_percentage': profitPercentage,
      'stock_quantity': stockQuantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      costPrice: map['cost_price'] as double,
      profitPercentage: map['profit_percentage'] as double,
      stockQuantity: map['stock_quantity'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Product copyWith({
    int? id,
    String? name,
    double? costPrice,
    double? profitPercentage,
    int? stockQuantity,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      costPrice: costPrice ?? this.costPrice,
      profitPercentage: profitPercentage ?? this.profitPercentage,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
