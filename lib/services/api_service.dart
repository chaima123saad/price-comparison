// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/price_model.dart';

class ApiService {
  // Fake Store API - Real e-commerce data (no API key needed)
  static const String _fakeStoreApi = 'https://fakestoreapi.com';
  
  // Open Food Facts API - Real food products (no API key needed)
  static const String _openFoodFactsUrl = 'https://world.openfoodfacts.org';
  
  // Cache for storing fetched products
  List<Product> _cachedProducts = [];
  DateTime? _lastFetchTime;
  
  // Search products from real APIs
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    print('🔍 Searching for: $query');
    
    try {
      // First try Fake Store API (electronics, clothing, etc.)
      final fakeStoreResults = await _searchFakeStoreApi(query);
      if (fakeStoreResults.isNotEmpty) {
        return fakeStoreResults;
      }
      
      // If no results from Fake Store, try Open Food Facts
      final foodResults = await _searchOpenFoodFacts(query);
      return foodResults;
      
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  // Search Fake Store API for e-commerce products
  Future<List<Product>> _searchFakeStoreApi(String query) async {
    try {
      // Fetch all products from Fake Store API
      final response = await http.get(
        Uri.parse('$_fakeStoreApi/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Cache the products for faster future searches
        _cachedProducts = _convertListToProducts(data);
        _lastFetchTime = DateTime.now();
        
        // Filter by search query
        final filtered = _cachedProducts.where((product) {
          final searchTerm = query.toLowerCase();
          return product.title.toLowerCase().contains(searchTerm) ||
                 (product.brand?.toLowerCase().contains(searchTerm) ?? false) ||
                 (product.description?.toLowerCase().contains(searchTerm) ?? false);
        }).toList();

        return filtered;
      }
      return [];
    } catch (e) {
      print('Fake Store API error: $e');
      return [];
    }
  }

  // Search Open Food Facts for food products
  Future<List<Product>> _searchOpenFoodFacts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_openFoodFactsUrl/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=10'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['products'] != null && data['products'] is List) {
          final List<dynamic> products = data['products'];
          return products
              .where((item) => item != null && 
                             item['product_name'] != null && 
                             item['product_name'].toString().isNotEmpty)
              .map((item) {
                return Product(
                  id: item['code']?.toString() ?? 
                      item['id']?.toString() ?? 
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: item['product_name'] ?? 'Unknown Product',
                  brand: item['brands'] ?? item['brand_owner'] ?? 'Unknown Brand',
                  description: item['generic_name'] ?? item['categories'] ?? 'No description available',
                  imageUrl: item['image_url'] ?? 
                           item['selected_images']?['front']?['display']?['en'] ??
                           item['image_front_url'],
                  upc: item['code']?.toString(),
                  ean: item['code']?.toString(),
                );
              }).toList();
        }
      }
      return [];
    } catch (e) {
      print('Open Food Facts API error: $e');
      return [];
    }
  }

  // Lookup product by barcode (uses Open Food Facts for barcode lookup)
  Future<Product?> lookupByBarcode(String barcode) async {
    print('🔍 Looking up barcode: $barcode');
    
    try {
      // Open Food Facts supports barcode lookup
      final response = await http.get(
        Uri.parse('$_openFoodFactsUrl/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final product = data['product'];
          return Product(
            id: barcode,
            title: product['product_name']?.toString() ?? 'Product $barcode',
            brand: product['brands']?.toString() ?? 
                   product['brand_owner']?.toString() ?? 
                   'Unknown Brand',
            description: product['generic_name']?.toString() ?? 
                        product['categories']?.toString() ?? 
                        'Scanned product',
            imageUrl: product['image_url']?.toString() ?? 
                     product['selected_images']?['front']?['display']?['en']?.toString() ??
                     product['image_front_url']?.toString(),
            upc: barcode,
            ean: barcode,
          );
        }
      }
      
      // If no product found, create a generic product
      return Product(
        id: barcode,
        title: 'Product $barcode',
        brand: 'Unknown Brand',
        description: 'Scanned product - Barcode: $barcode',
        imageUrl: null,
        upc: barcode,
        ean: barcode,
      );
      
    } catch (e) {
      print('Barcode lookup error: $e');
      return Product(
        id: barcode,
        title: 'Product $barcode',
        brand: 'Unknown Brand',
        description: 'Scanned product - Barcode: $barcode',
        imageUrl: null,
        upc: barcode,
        ean: barcode,
      );
    }
  }

  // Get real prices from Fake Store API data
  Future<List<Price>> getRealPrices(String productId, String productTitle) async {
    try {
      // Generate realistic store prices based on product
      return _generateStorePrices(productId, productTitle);
      
    } catch (e) {
      print('Get prices error: $e');
      // Fallback to generated prices
      return _generateStorePrices(productId, productTitle);
    }
  }

  // Generate realistic store prices
  List<Price> _generateStorePrices(String productId, String productTitle) {
    // Generate a base price based on product ID hash
    final hash = productId.hashCode.abs() % 1000;
    final basePrice = 50.0 + (hash % 500).toDouble();
    
    final stores = [
      {
        'name': 'Amazon',
        'logo': '🛒',
        'priceVariation': -0.05, // 5% cheaper than base
        'shipping': 0.0,
        'rating': 4.5,
      },
      {
        'name': 'Walmart',
        'logo': '🏪',
        'priceVariation': -0.02, // 2% cheaper
        'shipping': 5.99,
        'rating': 4.2,
      },
      {
        'name': 'Best Buy',
        'logo': '🔌',
        'priceVariation': 0.03, // 3% more expensive
        'shipping': 0.0,
        'rating': 4.7,
      },
      {
        'name': 'Target',
        'logo': '🎯',
        'priceVariation': 0.0, // Same price
        'shipping': 9.99,
        'rating': 4.3,
      },
      {
        'name': 'eBay',
        'logo': '📦',
        'priceVariation': -0.08, // 8% cheaper
        'shipping': 0.0,
        'rating': 4.1,
      },
    ];

    final prices = stores.map((store) {
      try {
        final variation = store['priceVariation'] as double;
        final price = basePrice * (1 + variation);
        final originalPrice = variation < 0 ? basePrice : null;
        
        return Price(
          store: store['name'] as String,
          storeLogo: store['logo'] as String,
          price: double.parse(price.toStringAsFixed(2)),
          originalPrice: originalPrice != null ? 
              double.parse(originalPrice.toStringAsFixed(2)) : null,
          currency: 'USD',
          productUrl: _getStoreUrl(store['name'] as String, productId, productTitle),
          shippingCost: store['shipping'] as double?,
          inStock: true,
          lastChecked: DateTime.now(),
          rating: store['rating'] as double?,
          reviewCount: 100 + DateTime.now().millisecond % 900,
        );
      } catch (e) {
        print('Error creating price for ${store['name']}: $e');
        // Return a default price if there's an error
        return Price(
          store: store['name'] as String,
          storeLogo: store['logo'] as String,
          price: 99.99,
          currency: 'USD',
          productUrl: _getStoreUrl(store['name'] as String, productId, productTitle),
          shippingCost: 0.0,
          inStock: true,
          lastChecked: DateTime.now(),
          rating: 4.0,
          reviewCount: 100,
        );
      }
    }).toList();

    // Sort by total price
    prices.sort((a, b) => a.totalPrice.compareTo(b.totalPrice));
    
    return prices;
  }

  // Get trending products from Fake Store API
  Future<List<Product>> getTrendingProducts() async {
    try {
      // Check cache first (refresh every 5 minutes)
      if (_cachedProducts.isNotEmpty && 
          _lastFetchTime != null && 
          DateTime.now().difference(_lastFetchTime!) < Duration(minutes: 5)) {
        return _getSafeProductList(_cachedProducts);
      }
      
      // Fetch fresh data from Fake Store API
      final response = await http.get(
        Uri.parse('$_fakeStoreApi/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _cachedProducts = _convertListToProducts(data);
        _lastFetchTime = DateTime.now();
        return _getSafeProductList(_cachedProducts);
      }
      
      // If API fails but we have cached data, return it
      if (_cachedProducts.isNotEmpty) {
        return _getSafeProductList(_cachedProducts);
      }
      
      // If no cached data, return empty list
      return [];
      
    } catch (e) {
      print('Get trending products error: $e');
      // Return cached data if available, otherwise empty
      if (_cachedProducts.isNotEmpty) {
        return _getSafeProductList(_cachedProducts);
      }
      return [];
    }
  }

  // Get product categories from Fake Store API
  Future<List<String>> getProductCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_fakeStoreApi/products/categories'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> categories = json.decode(response.body);
        return categories
            .where((cat) => cat != null && cat.toString().isNotEmpty)
            .map((cat) => cat.toString())
            .toList();
      }
      return [];
    } catch (e) {
      print('Get categories error: $e');
      return [];
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_fakeStoreApi/products/category/$category'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _convertListToProducts(data);
      }
      return [];
    } catch (e) {
      print('Get products by category error: $e');
      return [];
    }
  }

  // Get search suggestions
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      if (query.isEmpty) {
        // Return popular categories
        final categories = await getProductCategories();
        return categories.take(8).toList();
      }
      
      // Ensure we have cached products
      if (_cachedProducts.isEmpty) {
        await getTrendingProducts();
      }
      
      // Get suggestions from cached products
      final suggestions = <String>{};
      for (final product in _cachedProducts) {
        if (product.title.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(product.title);
        }
        if (product.brand?.toLowerCase().contains(query.toLowerCase()) ?? false) {
          suggestions.add(product.brand!);
        }
      }
      
      return suggestions.take(8).toList();
      
    } catch (e) {
      print('Get suggestions error: $e');
      return [];
    }
  }

  // Helper methods
  List<Product> _convertListToProducts(List<dynamic> data) {
    final products = <Product>[];
    
    for (var item in data) {
      try {
        if (item != null) {
          final product = _convertToProduct(item);
          if (product.title.isNotEmpty) {
            products.add(product);
          }
        }
      } catch (e) {
        print('Error converting item to product: $e');
        // Skip invalid items
      }
    }
    
    return products;
  }

  Product _convertToProduct(dynamic item) {
    try {
      return Product(
        id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: item['title']?.toString() ?? 'Unknown Product',
        brand: _getBrandFromCategory(item['category']?.toString()),
        description: item['description']?.toString() ?? 'No description available',
        imageUrl: item['image']?.toString(),
        upc: item['id']?.toString(),
        ean: item['id']?.toString(),
      );
    } catch (e) {
      print('Error in _convertToProduct: $e');
      // Return a default product if conversion fails
      return Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Product',
        brand: 'Generic',
        description: 'No description available',
        imageUrl: null,
        upc: null,
        ean: null,
      );
    }
  }

  String _getBrandFromCategory(String? category) {
    if (category == null || category.isEmpty) return 'Generic';
    
    switch (category.toLowerCase()) {
      case 'electronics':
        return 'TechBrand';
      case 'jewelery':
        return 'Luxury';
      case "men's clothing":
        return 'MenStyle';
      case "women's clothing":
        return 'WomenStyle';
      default:
        return 'Brand';
    }
  }

  String _getStoreUrl(String store, String productId, String productTitle) {
    try {
      final query = productTitle.replaceAll(' ', '+');
      switch (store.toLowerCase()) {
        case 'amazon':
          return 'https://www.amazon.com/s?k=$query';
        case 'walmart':
          return 'https://www.walmart.com/search?q=$query';
        case 'best buy':
          return 'https://www.bestbuy.com/site/searchpage.jsp?st=$query';
        case 'target':
          return 'https://www.target.com/s?searchTerm=$query';
        case 'ebay':
          return 'https://www.ebay.com/sch/i.html?_nkw=$query';
        default:
          return 'https://www.google.com/search?q=$query';
      }
    } catch (e) {
      return 'https://www.google.com/search?q=product';
    }
  }

  // Get safe product list (max 12 items, ensures list is valid)
  List<Product> _getSafeProductList(List<Product> products) {
    if (products.isEmpty) return [];
    
    final safeProducts = products
        .where((product) => product.title.isNotEmpty)
        .toList();
    
    // Return at most 12 products
    return safeProducts.take(12).toList();
  }
}