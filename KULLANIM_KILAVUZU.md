# Konsinye Takip Sistemi - Kullanım Kılavuzu

## Proje Hakkında

Bu uygulama, komşunuzdan konsinyeye aldığınız ürünlerin satış ve ödeme takibini yapmanızı sağlayan bir Windows masaüstü uygulamasıdır.

## İş Mantığı

- Ürünleri maliyet fiyatı ile alıyorsunuz
- Maliyet üzerine belirli bir kar yüzdesi ekleyerek satıyorsunuz
- Kar yarı yarıya paylaşılıyor (50% size, 50% komşunuza)
- Komşunuza ödemeniz gereken: **Maliyet + Komşunun kar payı**

### Örnek Hesaplama
- Maliyet: 3.000 TL
- Kar Yüzdesi: %33
- Satış Fiyatı: 4.000 TL
- Toplam Kar: 1.000 TL
- Sizin Payınız: 500 TL
- Komşunun Payı: 500 TL
- **Komşuya Ödeyeceğiniz: 3.500 TL**

## Kurulum

### Gereksinimler
- Flutter SDK (3.27.3 veya üzeri)
- Windows 10/11 (veya macOS/Linux test için)

### Kurulum Adımları

1. **Bağımlılıkları Yükleyin:**
   ```bash
   flutter pub get
   ```

2. **Windows'ta Çalıştırma:**
   ```bash
   flutter run -d windows
   ```

3. **Windows İçin Build:**
   ```bash
   flutter build windows --release
   ```
   Build edilen uygulama `build/windows/x64/runner/Release/` klasöründe olacaktır.

## Kullanım

### 1. Ana Sayfa (Dashboard)

Ana sayfada şu bilgileri görebilirsiniz:
- **Toplam Satış**: Yapılan tüm satışların toplam geliri
- **Benim Karım**: Size ait toplam kar payı
- **Toplam Borç**: Komşuya toplam borcunuz
- **Ödenen**: Komşuya yaptığınız toplam ödeme
- **Kalan Borç**: Komşuya ödemeniz gereken kalan tutar

Hızlı erişim butonları ile diğer ekranlara geçiş yapabilirsiniz.

### 2. Ürünler Ekranı

**Ürün Ekleme:**
- Sağ alttaki "+" butonuna tıklayın
- Ürün adı girin
- Maliyet fiyatını girin
- Kar yüzdesini girin (örn: 33 için %33 kar)
- Stok miktarını girin
- "Ekle" butonuna tıklayın

**Ürün Düzenleme:**
- Ürün kartındaki "Düzenle" ikonuna tıklayın
- Bilgileri güncelleyin
- "Güncelle" butonuna tıklayın

**Ürün Silme:**
- Ürün kartındaki "Sil" ikonuna tıklayın
- Onaylayın

### 3. Satış Ekranı

**Satış Yapma:**
- Sağ alttaki "+" butonuna tıklayın
- Açılan listeden ürün seçin
- Satış yapılacak ürün detaylarını görüntüleyin
  - Maliyet, satış fiyatı, kar paylaşımı otomatik gösterilir
- Satış adedini girin
- "Satışı Kaydet" butonuna tıklayın

**Not:**
- Satış yapıldığında stok otomatik olarak düşer
- Kar paylaşımı otomatik olarak hesaplanır
- Komşunun payı borç olarak eklenir

**Satış İptali:**
- Satış kartındaki "Sil" ikonuna tıklayın
- Onaylayın
- Stok geri eklenir

### 4. Ödeme Ekranı

**Ödeme Kaydetme:**
- Sağ alttaki "+" butonuna tıklayın
- Ödeme tutarını girin
- Ödeme tarihini seçin
- İsterseniz not ekleyin
- "Kaydet" butonuna tıklayın

**Ödeme Silme:**
- Ödeme kartındaki "Sil" ikonuna tıklayın
- Onaylayın

### 5. Raporlar Ekranı

**Genel Rapor:**
- Tüm finansal özet bilgileri
- Toplam satış, kar, borç bilgileri

**Ürünler Raporu:**
- Her ürün için detaylı bilgi
- Maliyet, satış fiyatı, kar analizi
- Stok durumu

**Hareketler:**
- **Satışlar Sekmesi**: Tüm satış geçmişi
- **Ödemeler Sekmesi**: Tüm ödeme geçmişi

## Teknik Detaylar

### Kullanılan Teknolojiler
- **Flutter**: UI Framework
- **Provider**: State Management
- **SQLite (sqflite_common_ffi)**: Yerel veritabanı
- **Intl**: Tarih ve para formatlaması

### Proje Yapısı
```
lib/
├── database/
│   └── database_helper.dart      # SQLite veritabanı yönetimi
├── models/
│   ├── product.dart              # Ürün modeli
│   ├── sale.dart                 # Satış modeli
│   └── payment.dart              # Ödeme modeli
├── providers/
│   ├── product_provider.dart     # Ürün state management
│   ├── sale_provider.dart        # Satış state management
│   ├── payment_provider.dart     # Ödeme state management
│   └── dashboard_provider.dart   # Dashboard state management
├── screens/
│   ├── dashboard_screen.dart     # Ana sayfa
│   ├── products_screen.dart      # Ürünler ekranı
│   ├── sales_screen.dart         # Satışlar ekranı
│   ├── payments_screen.dart      # Ödemeler ekranı
│   └── reports_screen.dart       # Raporlar ekranı
├── utils/
│   ├── currency_formatter.dart   # Para formatlaması
│   └── date_formatter.dart       # Tarih formatlaması
└── main.dart                     # Ana uygulama
```

### Veritabanı

Veritabanı otomatik olarak kullanıcının bilgisayarında oluşturulur:
- **Windows**: `%APPDATA%/konsinye/databases/konsinye.db`
- **macOS**: `~/Library/Application Support/konsinye/databases/konsinye.db`
- **Linux**: `~/.local/share/konsinye/databases/konsinye.db`

### Özellikler

✅ Ürün yönetimi (Ekleme, düzenleme, silme)
✅ Stok takibi (Otomatik stok güncelleme)
✅ Satış işlemleri (Kar hesaplama ve paylaşım)
✅ Ödeme takibi (Borç hesaplama)
✅ Detaylı raporlar ve analizler
✅ Türkçe arayüz
✅ Türk Lirası (₺) formatı
✅ Türkçe tarih formatı (dd.MM.yyyy)
✅ Modern ve kullanıcı dostu arayüz
✅ SQLite yerel veritabanı

## Sorun Giderme

### Uygulama açılmıyor
- Flutter'ın doğru kurulduğundan emin olun: `flutter doctor`
- Bağımlılıkları yeniden yükleyin: `flutter pub get`

### Veritabanı hatası
- Uygulama klasörüne yazma izni olduğundan emin olun
- Uygulamayı yönetici olarak çalıştırmayı deneyin

### Build hatası
- Flutter'ı güncelleyin: `flutter upgrade`
- Build klasörünü temizleyin: `flutter clean`
- Tekrar build edin: `flutter build windows --release`

## Güncelleme Geçmişi

### v1.0.0 (İlk Sürüm)
- Temel ürün yönetimi
- Satış takibi
- Ödeme takibi
- Raporlama sistemi
- Dashboard ekranı

## İletişim ve Destek

Herhangi bir sorun veya öneri için GitHub üzerinden issue açabilirsiniz.

---

**Not:** Bu uygulama kişisel kullanım için tasarlanmıştır. Tüm veriler yerel bilgisayarınızda saklanır ve hiçbir sunucuya gönderilmez.
