import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';

class CoinListItem extends StatelessWidget {
  final CryptoCurrency coin;
  final VoidCallback onTap;

  const CoinListItem({super.key, required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove margin to eliminate spacing
      elevation: 0.5, // Reduce elevation for a flatter look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Remove border radius
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coin.imageUrl,
                  height: 40,
                  width: 40,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.image_not_supported),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Symbol: ${coin.symbol.toUpperCase()}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'US\$${coin.currentPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  // Display price change percentage with color
                  Text(
                    '${coin.priceChangePercentage24h?.toStringAsFixed(2) ?? "0.00"}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          (coin.priceChangePercentage24h ?? 0) >= 0
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
