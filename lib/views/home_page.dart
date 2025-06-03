import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/crypto_view_model.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/category_grid_item.dart';
import 'detail_page.dart';
import 'category_detail_page.dart';
import 'auth/login_page.dart';
import '../viewModels/auth_view_model.dart';

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
          centerTitle: true,
          leading: Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return IconButton(
                icon: Icon(
                  authViewModel.isLoggedIn ? Icons.account_circle : Icons.login,
                  color: authViewModel.isLoggedIn ? Colors.green : Colors.white,
                ),
                onPressed: () {
                  if (authViewModel.isLoggedIn) {
                    _showUserMenu(context, authViewModel);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
              );
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/image/crypto_book_appbar_icon.png',
                height: 34,
                width: 34,
              ),
              SizedBox(width: 8),
              Text(
                '幣冊',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          bottom: TabBar(tabs: [Tab(text: '全部'), Tab(text: '類別')]),
        ),
        body: TabBarView(
          children: [_buildAllCoinsTab(), _buildCategoriesTab()],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, AuthViewModel authViewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.green),
                title: Text('已登入'),
                subtitle: Text(authViewModel.user?.email ?? ''),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('登出'),
                onTap: () {
                  Navigator.pop(context);
                  authViewModel.signOut();
                },
              ),
            ],
          ),
        );
      },
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
