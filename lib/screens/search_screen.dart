// lib/screens/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../widgets/product_card.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  
  SearchScreen({this.initialQuery});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];
  List<String> _categories = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchProducts(widget.initialQuery!);
      });
    }
    _loadRecentSearches();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final searches = await storage.getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _loadCategories() async {
    final api = Provider.of<ApiService>(context, listen: false);
    try {
      final categories = await api.getProductCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Failed to load categories: $e');
      // Fallback categories
      _categories = [
        'electronics',
        'jewelery',
        "men's clothing",
        "women's clothing",
      ];
    }
  }

  void _onSearchTextChanged(String value) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (value.isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchSuggestions.clear();
        _hasSearched = false;
      });
      return;
    }

    // Get instant suggestions
    _getSearchSuggestions(value);
    
    // Debounce the actual search
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _searchProducts(value);
    });
  }

  Future<void> _getSearchSuggestions(String query) async {
    final api = Provider.of<ApiService>(context, listen: false);
    try {
      final suggestions = await api.getSearchSuggestions(query);
      setState(() {
        _searchSuggestions = suggestions;
      });
    } catch (e) {
      print('Failed to get suggestions: $e');
      setState(() {
        _searchSuggestions = [];
      });
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      // Save to recent searches
      final storage = Provider.of<StorageService>(context, listen: false);
      await storage.addRecentSearch(query);

      // Perform search
      final api = Provider.of<ApiService>(context, listen: false);
      final results = await api.searchProducts(query);

      setState(() {
        _searchResults = results;
        _isSearching = false;
        // Update recent searches
        _recentSearches = [query, ..._recentSearches.where((s) => s != query).toList()];
        if (_recentSearches.length > 10) _recentSearches.removeLast();
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to search products. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _searchByCategory(String category) async {
    final api = Provider.of<ApiService>(context, listen: false);
    try {
      setState(() {
        _isSearching = true;
        _hasSearched = true;
        _searchController.text = category;
      });

      final results = await api.getProductsByCategory(category);
      
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Category search error: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
      _searchSuggestions.clear();
      _hasSearched = false;
    });
  }

  void _performInstantSearch(String query) {
    _searchController.text = query;
    _searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          child: custom_widgets.CustomSearchBar(
            controller: _searchController,
            hintText: 'Search products...',
            onChanged: _onSearchTextChanged,
            onClear: _clearSearch,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isSearching && _searchResults.isEmpty) {
      return _buildLoading();
    }

    if (_hasSearched) {
      return _buildSearchResults();
    }

    if (_searchController.text.isNotEmpty && _searchSuggestions.isNotEmpty) {
      return _buildSearchSuggestions();
    }

    return _buildRecentSearches();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Searching products...'),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Try searching with the same query again
                _searchProducts(_searchController.text);
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Suggestions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _searchSuggestions.map((suggestion) {
            return FilterChip(
              label: Text(suggestion),
              onSelected: (selected) {
                _performInstantSearch(suggestion);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: Colors.black87,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24),
        Text(
          'Try searching for:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        ..._getPopularCategories().map((category) {
          return ListTile(
            leading: Icon(Icons.category, color: Colors.grey),
            title: Text(category),
            trailing: Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _performInstantSearch(category),
          );
        }),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final storage = Provider.of<StorageService>(context, listen: false);
                  await storage.clearRecentSearches();
                  setState(() {
                    _recentSearches.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recent searches cleared')),
                  );
                },
                child: Text('Clear all'),
              ),
            ],
          ),
          SizedBox(height: 16),
          ..._recentSearches.map((search) {
            return Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.history, color: Colors.grey),
                title: Text(search),
                trailing: IconButton(
                  icon: Icon(Icons.close, size: 20),
                  onPressed: () async {
                    final storage = Provider.of<StorageService>(context, listen: false);
                    final searches = await storage.getRecentSearches();
                    searches.remove(search);
                    await storage.clearRecentSearches();
                    for (var s in searches) {
                      await storage.addRecentSearch(s);
                    }
                    setState(() {
                      _loadRecentSearches();
                    });
                  },
                ),
                onTap: () => _performInstantSearch(search),
              ),
            );
          }).toList(),
          SizedBox(height: 24),
        ],
        
        // Categories Section
        Text(
          'Browse Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _categories.map((category) {
            return Card(
              child: ListTile(
                leading: _getCategoryIcon(category),
                title: Text(
                  _formatCategoryName(category),
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () => _searchByCategory(category),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 24),

        // Popular Searches
        Text(
          'Popular Searches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _getPopularSearches().map((term) {
            return ActionChip(
              label: Text(term),
              onPressed: () {
                _performInstantSearch(term);
              },
            );
          }).toList(),
        ),

        SizedBox(height: 24),

        // Quick Search
        Text(
          'Quick Search',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            'Electronics',
            'Clothing',
            'Jewelry',
            'Accessories',
            'Home',
            'Sports',
          ].map((term) {
            return ElevatedButton(
              onPressed: () => _performInstantSearch(term),
              child: Text(term),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> _getPopularCategories() {
    return _categories.isNotEmpty 
        ? _categories.take(6).toList()
        : [
            'electronics',
            'jewelery',
            "men's clothing",
            "women's clothing",
            'home',
            'sports',
          ];
  }

  List<String> _getPopularSearches() {
    return [
      'Phone',
      'Laptop',
      'Watch',
      'Shoes',
      'Bag',
      'Camera',
      'Headphones',
      'Tablet',
    ];
  }

  Icon _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icon(Icons.electrical_services, color: Colors.blue);
      case 'jewelery':
        return Icon(Icons.diamond, color: Colors.amber);
      case "men's clothing":
        return Icon(Icons.male, color: Colors.blue);
      case "women's clothing":
        return Icon(Icons.female, color: Colors.pink);
      default:
        return Icon(Icons.category, color: Colors.grey);
    }
  }

String _formatCategoryName(String category) {
  if (category.isEmpty) return '';
  
  return category
      .replaceAll("'s", "'s ")
      .split(' ')
      .where((word) => word.isNotEmpty) // Filter out empty strings
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
}