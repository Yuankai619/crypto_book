import 'package:crypto_book/models/crypto_currency.dart';
import 'package:flutter/material.dart';
import '../viewModels/crypto_view_model.dart';
import '../widgets/crypto_card.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final CryptoViewModel viewModel = CryptoViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('幣冊'),
          bottom: TabBar(
            tabs: [Tab(text: '主流幣'), Tab(text: '穩定幣'), Tab(text: '迷因幣')],
          ),
        ),
        body:
            viewModel.isLoading
                ? Center(child: CircularProgressIndicator())
                : viewModel.error != null
                ? Center(
                  child: Text(
                    'Error: ${viewModel.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                )
                : TabBarView(
                  children: [
                    buildGridView(viewModel.mainstream),
                    buildGridView(viewModel.stablecoins),
                    buildGridView(viewModel.memecoins),
                  ],
                ),
      ),
    );
  }

  Widget buildGridView(List<CryptoCurrency> cryptos) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: cryptos.length,
      itemBuilder: (context, index) {
        return CryptoCard(
          crypto: cryptos[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(crypto: cryptos[index]),
              ),
            );
          },
        );
      },
    );
  }
}
