import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/crypto_view_model.dart';
import '../widgets/coin_list_item.dart';
import '../widgets/category_grid_item.dart';
import 'detail_page.dart';
import 'category_detail_page.dart';
import 'auth/login_page.dart';
import '../viewModels/auth_view_model.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CryptoViewModel>(context, listen: false);
      viewModel.loadCoins();
      viewModel.loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: !_isSearching,
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
        title: _isSearching ? _buildSearchField() : _buildTitle(),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: '全部'), Tab(text: '類別')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAllCoinsTab(), _buildCategoriesTab()],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/image/crypto_book_appbar_icon.png',
          height: 34,
          width: 34,
        ),
        SizedBox(width: 8),
        Text('幣冊', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '搜尋貨幣名稱或代號...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      style: TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
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
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.errorCoins}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadCoins(),
                  child: Text('重試'),
                ),
              ],
            ),
          );
        }

        // 過濾搜尋結果
        final filteredCoins =
            _searchQuery.isEmpty
                ? viewModel.coins
                : viewModel.coins.where((coin) {
                  return coin.name.toLowerCase().contains(_searchQuery) ||
                      coin.symbol.toLowerCase().contains(_searchQuery);
                }).toList();

        if (filteredCoins.isEmpty && _searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  '找不到符合的貨幣',
                  style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                ),
                SizedBox(height: 8),
                Text(
                  '請嘗試其他關鍵字',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadCoins();
          },
          child: ListView.builder(
            itemCount: filteredCoins.length,
            itemBuilder: (context, index) {
              final coin = filteredCoins[index];
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
          ),
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
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: ${viewModel.errorCategories}',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadCategories(),
                  child: Text('重試'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await viewModel.loadCategories();
          },
          child: GridView.builder(
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
          ),
        );
      },
    );
  }
}
