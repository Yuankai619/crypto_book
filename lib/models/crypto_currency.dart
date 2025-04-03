class CryptoCurrency {
  final String id;
  final String symbol;
  final String name;
  final String imageUrl;
  final double currentPrice;
  final double marketCap;
  final int? marketCapRank;
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
    );
  }

  factory CryptoCurrency.fromDetailJson(Map<String, dynamic> json) {
    var description = '';
    if (json['description'] != null && json['description']['en'] != null) {
      description = json['description']['en'];
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
