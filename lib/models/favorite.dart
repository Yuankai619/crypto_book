class Favorite {
  final String id;
  final String userId;
  final String coinId;
  final String coinName;
  final String coinSymbol;
  final String imageUrl;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.coinId,
    required this.coinName,
    required this.coinSymbol,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      coinId: map['coinId'] ?? '',
      coinName: map['coinName'] ?? '',
      coinSymbol: map['coinSymbol'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'coinId': coinId,
      'coinName': coinName,
      'coinSymbol': coinSymbol,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
