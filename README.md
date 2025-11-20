# Konsinye Takip Sistemi

Modern ve kullanıcı dostu bir konsinye ürün takip uygulaması. Flutter ile geliştirilmiş, Windows ve macOS platformlarında çalışır.

## Özellikler

### Ürün Yönetimi
- Ürün ekleme, düzenleme ve silme
- Maliyet fiyatı ve kar yüzdesi ile otomatik satış fiyatı hesaplama
- Stok takibi
- Ürün listesi ve detayları

### Satış Yönetimi
- Satış kaydı oluşturma
- Otomatik stok güncelleme
- Kar paylaşımı hesaplama (komşu payı / kendi payı)
- Satış geçmişi

### Ödeme Takibi
- Komşuya yapılan ödemeleri kaydetme
- Ödeme geçmişi
- Notlar ekleme

### Raporlama
- Toplam satış geliri
- Komşuya borçlu olunan tutar
- Yapılan ödemeler
- Kalan borç hesaplama
- Kendi kar payı

### Dark Mode
- Açık ve koyu tema desteği
- Tema tercihi otomatik kaydedilir
- Göz dostu renk paleti

## Kurulum

### Gereksinimler
- Flutter SDK (3.6.1 veya üzeri)
- Dart SDK
- macOS/Windows işletim sistemi

### Adımlar

1. Projeyi klonlayın:
\`\`\`bash
git clone https://github.com/sakinburakcivelek/konsinye.git
cd konsinye
\`\`\`

2. Bağımlılıkları yükleyin:
\`\`\`bash
flutter pub get
\`\`\`

3. Uygulamayı çalıştırın:
\`\`\`bash
# macOS için
flutter run -d macos

# Windows için
flutter run -d windows
\`\`\`

## Kullanılan Teknolojiler

- **Flutter**: UI framework
- **Provider**: State management
- **SQLite (sqflite_common_ffi)**: Yerel veritabanı
- **SharedPreferences**: Tema tercihlerini saklama
- **Intl**: Tarih ve para birimi formatlama

## Proje Yapısı

\`\`\`
lib/
├── database/         # Veritabanı işlemleri
├── models/           # Veri modelleri
├── providers/        # State management
├── screens/          # UI ekranları
├── theme/            # Tema tanımlamaları
└── utils/            # Yardımcı fonksiyonlar
\`\`\`

## Veritabanı Şeması

### Products (Ürünler)
- id, name, cost_price, profit_percentage, stock_quantity, created_at

### Sales (Satışlar)
- id, product_id, product_name, quantity, cost_price, sale_price, sale_date, profit_amount, owner_share, my_share

### Payments (Ödemeler)
- id, amount, payment_date, note

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## İletişim

Sakın Burak Civelek - [@sakinburakcivelek](https://github.com/amITranquil)

Proje Linki: [https://github.com/sakinburakcivelek/konsinye](https://github.com/sakinburakcivelek/konsinye)
