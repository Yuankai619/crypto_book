class CryptoCurrency {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketCap;
  final int? marketCapRank;
  final double? priceChangePercentage24h;
  final String? description;
  final List<String>? categories;
  final Map<String, dynamic>? links;
  final String? countryOrigin;
  final String? genesisDate;

  CryptoCurrency({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketCap,
    this.marketCapRank,
    this.priceChangePercentage24h,
    this.description,
    this.categories,
    this.links,
    this.countryOrigin,
    this.genesisDate,
  });

  factory CryptoCurrency.fromMarketJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      marketCapRank: json['market_cap_rank'],
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] ?? 0).toDouble(),
    );
  }

  factory CryptoCurrency.fromDetailJson(Map<String, dynamic> json) {
    var description = '';
    if (json['description'] != null && json['description']['en'] != null) {
      description = json['description']['en'];
    }

    var priceChangePercentage24h = 0.0;
    if (json['market_data'] != null &&
        json['market_data']['price_change_percentage_24h'] != null) {
      priceChangePercentage24h =
          json['market_data']['price_change_percentage_24h'].toDouble();
    }

    return CryptoCurrency(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image']?['large'] ?? '',
      currentPrice:
          json['market_data']?['current_price']?['usd']?.toDouble() ?? 0,
      marketCap: json['market_data']?['market_cap']?['usd']?.toDouble() ?? 0,
      marketCapRank: json['market_cap_rank'],
      priceChangePercentage24h: priceChangePercentage24h,
      description: description,
      categories:
          json['categories'] != null
              ? List<String>.from(json['categories'])
              : [],
      links: json['links'],
      countryOrigin: json['country_origin'],
      genesisDate: json['genesis_date'],
    );
  }
}
