// lib/models/product_model.dart
class Product {
  final String id;
  final String title;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String? upc;
  final String? ean;
  final List<String>? offers;
  final DateTime? lastUpdated;

  Product({
    required this.id,
    required this.title,
    this.brand,
    this.description,
    this.imageUrl,
    this.upc,
    this.ean,
    this.offers,
    this.lastUpdated,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['asin'] ?? json['upc'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? json['product_name'] ?? 'Unknown Product',
      brand: json['brand'] ?? json['manufacturer'],
      description: json['description'] ?? json['features']?.join(', '),
      imageUrl: _getImageUrl(json),
      upc: json['upc'] ?? json['ean'],
      ean: json['ean'],
      offers: json['offers'] is List ? List<String>.from(json['offers']) : null,
      lastUpdated: json['last_update'] != null 
          ? DateTime.tryParse(json['last_update'])
          : null,
    );
  }

  static String? _getImageUrl(Map<String, dynamic> json) {
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      return json['images'][0];
    }
    return json['image'] ?? json['image_url'];
  }
}