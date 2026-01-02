// lib/screens/product_detail_screen.dart - FIXED VERSION with white text buttons
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/price_card.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import '../models/price_model.dart';
import '../utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<Price>> _prices;
  bool _isFavorite = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _prices = Provider.of<ApiService>(context, listen: false)
        .getRealPrices(widget.product.id, widget.product.title);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final isFav = await storage.isFavorite(widget.product.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    
    if (_isFavorite) {
      await storage.removeFromFavorites(widget.product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await storage.addToFavorites(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  Future<void> _launchUrl(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch URL')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _refreshPrices() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      final newPrices = await Provider.of<ApiService>(context, listen: false)
          .getRealPrices(widget.product.id, widget.product.title);
      
      setState(() {
        _prices = Future.value(newPrices);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prices updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update prices')),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showPriceAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Price Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Get notified when the price drops below your target.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Target Price (\$)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Price alert set successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Set Alert'),
          ),
        ],
      ),
    );
  }

  // FIXED: Safe method to display product ID
  String _getSafeProductId() {
    final id = widget.product.id;
    if (id.isEmpty) return 'N/A';
    
    // Safe truncation - only truncate if long enough
    if (id.length > 8) {
      return 'ID: ${id.substring(0, 8)}...';
    }
    return 'ID: $id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with product image
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.imageUrl != null
                  ? Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
                    ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Brand
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            if (widget.product.brand != null)
                              Text(
                                widget.product.brand!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Product ID/Code - FIXED
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.qr_code, size: 20, color: AppColors.primary),
                            SizedBox(height: 2),
                            Text(
                              _getSafeProductId(),
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Description
                  if (widget.product.description != null && 
                      widget.product.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.product.description!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 24),

                  // Price Comparison Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📊 Price Comparison',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: _isRefreshing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.refresh),
                        onPressed: _isRefreshing ? null : _refreshPrices,
                        tooltip: 'Refresh Prices',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Comparing prices from different stores',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Prices List
          FutureBuilder<List<Price>>(
            future: _prices,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading prices...'),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load prices',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshPrices,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.price_check, size: 50, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No price data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshPrices,
                            child: Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final prices = snapshot.data!;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final price = prices[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: PriceCard(
                        price: price,
                        onTap: () => _launchUrl(price.productUrl),
                      ),
                    );
                  },
                  childCount: prices.length,
                ),
              );
            },
          ),

          // Bottom Padding
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Bottom Action Bar with WHITE TEXT BUTTONS
      bottomSheet: FutureBuilder<List<Price>>(
        future: _prices,
        builder: (context, snapshot) {
          final prices = snapshot.data ?? [];
          final hasPrices = prices.isNotEmpty;
          
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Set Alert Button - WHITE TEXT
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showPriceAlertDialog,
                    icon: Icon(Icons.notifications_active, color: Colors.white),
                    label: Text(
                      'Set Alert',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                
                // Buy Now Button - WHITE TEXT
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasPrices
                        ? () => _launchUrl(prices.first.productUrl)
                        : null,
                    icon: Icon(Icons.shopping_cart, color: Colors.white),
                    label: Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: hasPrices ? AppColors.success : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}