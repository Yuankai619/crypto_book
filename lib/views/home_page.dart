import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/crypto_view_model.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/category_grid_item.dart';
import 'detail_page.dart';
import 'category_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CryptoViewModel>(context, listen: false);
      viewModel.loadCoins();
      viewModel.loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('幣冊'),
          bottom: TabBar(tabs: [Tab(text: '全部'), Tab(text: '類別')]),
        ),
        body: TabBarView(
          children: [_buildAllCoinsTab(), _buildCategoriesTab()],
        ),
      ),
    );
  }

  Widget _buildAllCoinsTab() {
    return Consumer<CryptoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingCoins) {
          return Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorCoins != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${viewModel.errorCoins}',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadCoins(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.coins.length,
          itemBuilder: (context, index) {
            final coin = viewModel.coins[index];
            return CoinListItem(
              coin: coin,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(coinId: coin.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<CryptoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingCategories) {
          return Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorCategories != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${viewModel.errorCategories}',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadCategories(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: viewModel.categories.length,
          itemBuilder: (context, index) {
            final category = viewModel.categories[index];
            return CategoryGridItem(
              category: category,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CategoryDetailPage(category: category),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
