import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';

class CoinListItem extends StatelessWidget {
  final CryptoCurrency coin;
  final VoidCallback onTap;

  const CoinListItem({super.key, required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                  Text(
                    'Market Cap: US\$${_formatMarketCap(coin.marketCap)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1000000000) {
      return '${(marketCap / 1000000000).toStringAsFixed(2)}B';
    } else if (marketCap >= 1000000) {
      return '${(marketCap / 1000000).toStringAsFixed(2)}M';
    } else if (marketCap >= 1000) {
      return '${(marketCap / 1000).toStringAsFixed(2)}K';
    } else {
      return marketCap.toString();
    }
  }
}
