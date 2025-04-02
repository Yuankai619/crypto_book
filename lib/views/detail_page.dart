import 'package:flutter/material.dart';
import '../models/crypto_currency.dart';

class DetailPage extends StatelessWidget {
  final CryptoCurrency crypto;

  const DetailPage({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(crypto.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              crypto.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crypto.name,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '市值: ${crypto.marketCap}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '簡述',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(crypto.description),
                  SizedBox(height: 16),
                  Text(
                    '應用面',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(crypto.application),
                  SizedBox(height: 16),
                  Text(
                    '基本面',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(crypto.fundamentals),
                  SizedBox(height: 16),
                  Text(
                    '消息面',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(crypto.news),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
