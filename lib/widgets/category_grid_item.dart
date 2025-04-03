import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryGridItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children:
                    category.top3CoinsImages.map((url) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundImage: NetworkImage(url),
                          backgroundColor: Colors.grey[800],
                          onBackgroundImageError: (_, __) {},
                        ),
                      );
                    }).toList(),
              ),
              const Spacer(),
              Text(
                'Market Cap: ${_formatMarketCap(category.marketCap)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 4),
              Text(
                '24h Change: ${category.marketCapChange24h.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      category.marketCapChange24h >= 0
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1000000000000) {
      return 'US\$${(marketCap / 1000000000000).toStringAsFixed(2)}T';
    } else if (marketCap >= 1000000000) {
      return 'US\$${(marketCap / 1000000000).toStringAsFixed(2)}B';
    } else if (marketCap >= 1000000) {
      return 'US\$${(marketCap / 1000000).toStringAsFixed(2)}M';
    } else {
      return 'US\$${(marketCap / 1000).toStringAsFixed(2)}K';
    }
  }
}
