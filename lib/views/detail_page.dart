import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/crypto_view_model.dart';
import '../models/crypto_currency.dart';

class DetailPage extends StatefulWidget {
  final String coinId;

  const DetailPage({super.key, required this.coinId});

  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  late Future<CryptoCurrency> _coinFuture;

  @override
  void initState() {
    super.initState();
    _coinFuture = Provider.of<CryptoViewModel>(
      context,
      listen: false,
    ).getCoinDetails(widget.coinId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('幣種詳情')),
      body: FutureBuilder<CryptoCurrency>(
        future: _coinFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _coinFuture = Provider.of<CryptoViewModel>(
                          context,
                          listen: false,
                        ).getCoinDetails(widget.coinId);
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final coin = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with image
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[850],
                  child: Center(
                    child: Image.network(
                      coin.imageUrl,
                      height: 120,
                      width: 120,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              Icon(Icons.image_not_supported, size: 80),
                    ),
                  ),
                ),

                // Coin information
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coin.name,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  coin.symbol.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'US\$${coin.currentPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (coin.marketCapRank != null)
                                Text(
                                  'Rank #${coin.marketCapRank}',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Market Cap
                      _buildInfoSection(
                        'Market Cap',
                        'US\$${_formatNumber(coin.marketCap)}',
                      ),

                      // Categories if available
                      if (coin.categories != null &&
                          coin.categories!.isNotEmpty)
                        _buildCategoriesSection(coin.categories!),

                      // Description if available
                      if (coin.description != null &&
                          coin.description!.isNotEmpty)
                        _buildDescriptionSection(coin.description!),

                      // Genesis date if available
                      if (coin.genesisDate != null &&
                          coin.genesisDate!.isNotEmpty)
                        _buildInfoSection('Genesis Date', coin.genesisDate!),

                      // Country origin if available
                      if (coin.countryOrigin != null &&
                          coin.countryOrigin!.isNotEmpty)
                        _buildInfoSection(
                          'Country Origin',
                          coin.countryOrigin!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                categories.map((category) {
                  return Chip(
                    label: Text(category),
                    backgroundColor: Colors.grey[800],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    // Remove HTML tags
    String plainText = description.replaceAll(RegExp(r'<[^>]*>'), '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(plainText),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000000000000) {
      return '${(number / 1000000000000).toStringAsFixed(2)}T';
    } else if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    } else {
      return number.toString();
    }
  }
}
