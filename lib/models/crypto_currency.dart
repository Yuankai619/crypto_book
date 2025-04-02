class CryptoCurrency {
  final String name;
  final String imageUrl;
  final String description;
  final String marketCap;
  final String application;
  final String fundamentals;
  final String news;

  CryptoCurrency({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.marketCap,
    required this.application,
    required this.fundamentals,
    required this.news,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      marketCap: json['marketCap'],
      application: json['application'],
      fundamentals: json['fundamentals'],
      news: json['news'],
    );
  }
}
