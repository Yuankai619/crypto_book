import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crypto_currency.dart';
import '../models/category.dart';

class ApiService {
  final String baseUrl = 'https://api.coingecko.com/api/v3';

  Future<List<CryptoCurrency>> getCoins({
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/coins/markets?vs_currency=usd&per_page=$perPage&page=$page',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((coin) => CryptoCurrency.fromMarketJson(coin)).toList();
    } else {
      throw Exception('Failed to load coins: ${response.statusCode}');
    }
  }

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/coins/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<CryptoCurrency> getCoinDetails(String id) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/coins/$id?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CryptoCurrency.fromDetailJson(data);
    } else {
      throw Exception('Failed to load coin details: ${response.statusCode}');
    }
  }
}
