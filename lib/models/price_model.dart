// lib/models/price_model.dart
class Price {
  final String store;
  final String storeLogo;
  final double price;
  final double? originalPrice;
  final String currency;
  final String productUrl;
  final double? shippingCost;
  final bool inStock;
  final DateTime lastChecked;
  final double? rating;
  final int? reviewCount;

  Price({
    required this.store,
    required this.storeLogo,
    required this.price,
    this.originalPrice,
    this.currency = 'USD',
    required this.productUrl,
    this.shippingCost,
    required this.inStock,
    required this.lastChecked,
    this.rating,
    this.reviewCount,
  });

  double get totalPrice => price + (shippingCost ?? 0);
  double? get discountPercent {
    if (originalPrice != null && originalPrice! > price) {
      return ((originalPrice! - price) / originalPrice!) * 100;
    }
    return null;
  }
}