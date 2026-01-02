import 'package:flutter/material.dart';
import '../models/price_model.dart';
import '../utils/constants.dart';

class PriceCard extends StatelessWidget {
  final Price price;
  final VoidCallback onTap;

  const PriceCard({
    Key? key,
    required this.price,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Store Logo/Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStoreColor(price.store).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  price.storeLogo,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),

            SizedBox(width: 16),

            // Store Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        price.store,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (price.rating != null) ...[
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            SizedBox(width: 2),
                            Text(
                              price.rating!.toStringAsFixed(1),
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 4),

                  // Price Info
                  Row(
                    children: [
                      Text(
                        '\$${price.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (price.originalPrice != null) ...[
                        SizedBox(width: 8),
                        Text(
                          '\$${price.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${price.discountPercent!.toStringAsFixed(0)}% OFF',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 4),

                  // Shipping and Stock
                  Row(
                    children: [
                      if (price.shippingCost != null && price.shippingCost! > 0)
                        Text(
                          '+ \$${price.shippingCost!.toStringAsFixed(2)} shipping',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      if (price.shippingCost == 0 || price.shippingCost == null)
                        Text(
                          'Free shipping',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                          ),
                        ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: price.inStock 
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          price.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: price.inStock ? AppColors.success : AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Total Price
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total: ',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '\$${price.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Visit Store →',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStoreColor(String store) {
    switch (store.toLowerCase()) {
      case 'amazon':
        return Color(0xFFFF9900);
      case 'walmart':
        return Color(0xFF0071CE);
      case 'best buy':
        return Color(0xFF003B64);
      case 'target':
        return Color(0xFFCC0000);
      case 'ebay':
        return Color(0xFFE53238);
      default:
        return AppColors.primary;
    }
  }
}