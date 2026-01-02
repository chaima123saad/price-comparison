// lib/screens/barcode_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import 'product_detail_screen.dart';
import '../utils/constants.dart';

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isLoading = false;
  String? _scanResult;

  Future<void> _scanBarcode() async {
    if (_barcodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a barcode')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _scanResult = null;
    });

    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final product = await api.lookupByBarcode(_barcodeController.text.trim());

      if (product != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      } else {
        setState(() {
          _scanResult = 'Product not found';
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Barcode'),
        content: TextField(
          controller: _barcodeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter UPC/EAN barcode',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _scanBarcode();
            },
            child: Text('Lookup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(Icons.keyboard),
            onPressed: _showManualEntryDialog,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Scan Barcode',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Point your camera at a product barcode to scan it',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 32),
              if (_isLoading)
                CircularProgressIndicator()
              else if (_scanResult != null)
                Text(
                  _scanResult!,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showManualEntryDialog,
                icon: Icon(Icons.keyboard),
                label: Text('Enter Barcode Manually'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _barcodeController.text = '883974959450';
                  _scanBarcode();
                },
                icon: Icon(Icons.smartphone),
                label: Text('Try Demo (iPhone UPC)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}