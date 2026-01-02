// lib/screens/recent_searches_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import 'search_screen.dart';
import '../utils/constants.dart';

class RecentSearchesScreen extends StatefulWidget {
  @override
  _RecentSearchesScreenState createState() => _RecentSearchesScreenState();
}

class _RecentSearchesScreenState extends State<RecentSearchesScreen> {
  late Future<List<String>> _recentSearches;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    _recentSearches = storage.getRecentSearches();
  }

  Future<void> _clearAllSearches() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    await storage.clearRecentSearches();
    setState(() {
      _loadRecentSearches();
    });
  }

  void _performSearch(String query, BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(initialQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Searches'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _clearAllSearches,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _recentSearches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No recent searches',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your search history will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRecentSearches,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                ...snapshot.data!.map((search) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.history, color: AppColors.primary),
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
                      onTap: () => _performSearch(search, context),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}