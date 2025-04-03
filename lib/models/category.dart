class Category {
  final String id;
  final String name;
  final double marketCap;
  final double marketCapChange24h;
  final String content;
  final List<String> top3CoinsId;
  final List<String> top3CoinsImages;
  final double volume24h;

  Category({
    required this.id,
    required this.name,
    required this.marketCap,
    required this.marketCapChange24h,
    required this.content,
    required this.top3CoinsId,
    required this.top3CoinsImages,
    required this.volume24h,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      marketCapChange24h: (json['market_cap_change_24h'] ?? 0).toDouble(),
      content: json['content'] ?? '',
      top3CoinsId:
          json['top_3_coins_id'] != null
              ? List<String>.from(json['top_3_coins_id'])
              : [],
      top3CoinsImages:
          json['top_3_coins'] != null
              ? List<String>.from(json['top_3_coins'])
              : [],
      volume24h: (json['volume_24h'] ?? 0).toDouble(),
    );
  }
}
