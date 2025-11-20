import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/payment.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('konsinye.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await databaseFactoryFfi.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ),
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Version 2: sales tablosuna cost_price kolonu ekleniyor
      await db.execute('ALTER TABLE sales ADD COLUMN cost_price REAL NOT NULL DEFAULT 0.0');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Products tablosu
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        cost_price $realType,
        profit_percentage $realType,
        stock_quantity $intType,
        created_at $textType
      )
    ''');

    // Sales tablosu
    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        product_id $intType,
        product_name $textType,
        quantity $intType,
        cost_price $realType,
        sale_price $realType,
        sale_date $textType,
        profit_amount $realType,
        owner_share $realType,
        my_share $realType,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // Payments tablosu
    await db.execute('''
      CREATE TABLE payments (
        id $idType,
        amount $realType,
        payment_date $textType,
        note TEXT
      )
    ''');
  }

  // PRODUCT İŞLEMLERİ
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'created_at DESC');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProductStock(int productId, int newQuantity) async {
    final db = await database;
    return await db.update(
      'products',
      {'stock_quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // SALE İŞLEMLERİ
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    return await db.insert('sales', sale.toMap());
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final result = await db.query('sales', orderBy: 'sale_date DESC');
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<Sale>> getSalesByProduct(int productId) async {
    final db = await database;
    final result = await db.query(
      'sales',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'sale_date DESC',
    );
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  Future<Sale?> getSale(int id) async {
    final db = await database;
    final maps = await db.query(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Sale.fromMap(maps.first);
  }

  Future<int> deleteSale(int id) async {
    final db = await database;
    return await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PAYMENT İŞLEMLERİ
  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final result = await db.query('payments', orderBy: 'payment_date DESC');
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  Future<Payment?> getPayment(int id) async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  Future<int> deletePayment(int id) async {
    final db = await database;
    return await db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // İSTATİSTİK İŞLEMLERİ
  Future<double> getTotalSalesRevenue() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(sale_price * quantity) as total FROM sales',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalOwnerShareFromSales() async {
    final db = await database;
    // Komşuya ödenecek = Her satıştan (maliyet + komşu kâr payı) * adet
    final result = await db.rawQuery(
      'SELECT SUM((cost_price + owner_share) * quantity) as total FROM sales',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalPaymentsToOwner() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM payments',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getRemainingDebtToOwner() async {
    final totalOwed = await getTotalOwnerShareFromSales();
    final totalPaid = await getTotalPaymentsToOwner();
    return totalOwed - totalPaid;
  }

  Future<double> getTotalMyProfit() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(my_share * quantity) as total FROM sales',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Elimdeki ürünlerin toplam değeri (maliyet + komşu kâr payı) * stok
  Future<double> getTotalInventoryValue() async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(
        (cost_price + (cost_price * profit_percentage / 100 / 2)) * stock_quantity
      ) as total
      FROM products
      WHERE stock_quantity > 0
      ''',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Elimdeki ürünlerden benim kârım (benim kâr payım * stok)
  Future<double> getTotalInventoryMyProfit() async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(
        (cost_price * profit_percentage / 100 / 2) * stock_quantity
      ) as total
      FROM products
      WHERE stock_quantity > 0
      ''',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
