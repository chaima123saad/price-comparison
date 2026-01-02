// lib/screens/home_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import 'search_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _trendingProducts;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadTrendingProducts();
  }

  Future<void> _loadTrendingProducts() async {
    setState(() {
      _trendingProducts = Provider.of<ApiService>(context, listen: false).getTrendingProducts();
    });
  }

  void _showNotificationSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🔔 You have new price drop alerts!',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTrendingProducts,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // Fixed AppBar
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                expandedHeight: 0,
                toolbarHeight: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),

              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    children: [
                      // Profile and Time Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price Compare',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _userName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.notifications_outlined),
                            onPressed: _showNotificationSnackbar,
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(Icons.person, color: AppColors.primary, size: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Search Bar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                    child: AbsorbPointer(
                      child: custom_widgets.CustomSearchBar(
                        hintText: 'Search products or scan barcode...',
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ),
              ),

              // Super Sale Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.primary, Color(0xFF00C853)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Super Sale Discount',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'up to 50%',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                'Welcome',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Icon(
                        Icons.shopping_bag,
                        size: 80,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildCategoryItem('Shoes', Icons.sports),
                      _buildCategoryItem('Beauty', Icons.spa),
                      _buildCategoryItem("Women's Fashion", Icons.woman),
                      _buildCategoryItem('Jewelry', Icons.diamond),
                      _buildCategoryItem("Men's Fashion", Icons.man),
                    ],
                  ),
                ),
              ),

              // Special For You Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Special For You',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchScreen()),
                          );
                        },
                        child: Text(
                          'See all',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Trending Products Grid
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: FutureBuilder<List<Product>>(
                  future: _trendingProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          childCount: 4,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 50, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Failed to load products',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadTrendingProducts,
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
                        child: Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag, size: 50, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No products available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final products = snapshot.data!.take(4).toList();

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          );
                        },
                        childCount: products.length,
                      ),
                    );
                  },
                ),
              ),

              // Bottom padding for better scrolling
              SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}