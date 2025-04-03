import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../viewModels/crypto_view_model.dart';
import '../widgets/coin_list_item.dart';
import 'detail_page.dart';

class CategoryDetailPage extends StatelessWidget {
  final Category category;

  const CategoryDetailPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category info
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[850],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Market Cap: ${_formatMarketCap(category.marketCap)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '24h Change: ${category.marketCapChange24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          category.marketCapChange24h >= 0
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Top coins row
                  if (category.top3CoinsImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Coins',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            category.top3CoinsImages.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  if (index < category.top3CoinsId.length) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetailPage(
                                              coinId:
                                                  category.top3CoinsId[index],
                                            ),
                                      ),
                                    );
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.grey[800],
                                  backgroundImage: NetworkImage(
                                    category.top3CoinsImages[index],
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Description section
            if (category.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(category.content),
                  ],
                ),
              ),

            // Coins in this category
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Coins in this Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            _buildCoinsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinsList(BuildContext context) {
    return Consumer<CryptoViewModel>(
      builder: (context, viewModel, child) {
        // Filter coins that belong to this category
        final categoryCoins =
            viewModel.coins
                .where(
                  (coin) => coin.categories?.contains(category.name) ?? false,
                )
                .toList();

        if (categoryCoins.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text('No coins found in this category')),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: categoryCoins.length,
          itemBuilder: (context, index) {
            return CoinListItem(
              coin: categoryCoins[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            DetailPage(coinId: categoryCoins[index].id),
                  ),
                );
              },
            );
          },
        );
      },
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
