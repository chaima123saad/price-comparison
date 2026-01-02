// lib/screens/price_alerts_screen.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PriceAlert {
  final String id;
  final String productName;
  final String productImage;
  final double currentPrice;
  final double targetPrice;
  final DateTime createdDate;

  PriceAlert({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.currentPrice,
    required this.targetPrice,
    required this.createdDate,
  });
}

class PriceAlertsScreen extends StatefulWidget {
  @override
  _PriceAlertsScreenState createState() => _PriceAlertsScreenState();
}

class _PriceAlertsScreenState extends State<PriceAlertsScreen> {
  List<PriceAlert> _alerts = [
    PriceAlert(
      id: '1',
      productName: 'Wireless Headphones',
      productImage: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
      currentPrice: 89.99,
      targetPrice: 79.99,
      createdDate: DateTime.now().subtract(Duration(days: 2)),
    ),
    PriceAlert(
      id: '2',
      productName: 'Smart Watch',
      productImage: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
      currentPrice: 299.99,
      targetPrice: 249.99,
      createdDate: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  void _showAddAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Price Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Current Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Target Price',
                border: OutlineInputBorder(),
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
              setState(() {
                _alerts.add(PriceAlert(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  productName: 'New Product Alert',
                  productImage: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
                  currentPrice: 99.99,
                  targetPrice: 79.99,
                  createdDate: DateTime.now(),
                ));
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Price alert added successfully!')),
              );
            },
            child: Text('Add Alert'),
          ),
        ],
      ),
    );
  }

  void _deleteAlert(String id) {
    setState(() {
      _alerts.removeWhere((alert) => alert.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Price Alerts'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert),
            onPressed: _showAddAlertDialog,
          ),
        ],
      ),
      body: _alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No price alerts',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Set alerts for price drops',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddAlertDialog,
                    icon: Icon(Icons.add),
                    label: Text('Add Alert'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final priceDiff = alert.currentPrice - alert.targetPrice;
                final progress = (alert.currentPrice - alert.targetPrice) / alert.currentPrice;

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: NetworkImage(alert.productImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Current: \$${alert.currentPrice}',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    'Target: \$${alert.targetPrice}',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  priceDiff > 0 ? AppColors.success : AppColors.warning,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                priceDiff > 0
                                    ? '\$${priceDiff.toStringAsFixed(2)} to go'
                                    : 'Price reached!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: priceDiff > 0 ? AppColors.warning : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _deleteAlert(alert.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}