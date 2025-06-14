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
import 'user_info_page.dart';
import 'ai_chat_page.dart';
import '../viewModels/user_info_view_model.dart';

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

      // Load user info to get avatar
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.isLoggedIn) {
        final userInfoViewModel = Provider.of<UserInfoViewModel>(
          context,
          listen: false,
        );
        userInfoViewModel.loadUserInfo();
      }

      // 監聽認證狀態變化
      authViewModel.addListener(() {
        if (authViewModel.isLoggedIn) {
          final userInfoViewModel = Provider.of<UserInfoViewModel>(
            context,
            listen: false,
          );
          userInfoViewModel.loadUserInfo();
        }
      });
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
        leading: Consumer2<AuthViewModel, UserInfoViewModel>(
          builder: (context, authViewModel, userInfoViewModel, child) {
            if (!authViewModel.isLoggedIn) {
              // 未登入時顯示登入圖示
              return IconButton(
                icon: Icon(Icons.login, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              );
            }

            // 已登入時顯示頭像
            final user = userInfoViewModel.currentUser;
            final hasAvatar = user?.avatar != null && user!.avatar!.isNotEmpty;

            return IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoPage()),
                );
              },
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: ClipOval(
                  child:
                      hasAvatar
                          ? Image.network(
                            user.avatar!,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                color: Colors.green,
                                size: 28,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 28,
                                height: 28,
                                color: Colors.grey[700],
                                child: Icon(
                                  Icons.account_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                              );
                            },
                          )
                          : Icon(
                            Icons.account_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                ),
              ),
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
            icon: Icon(Icons.smart_toy),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AiChatPage()),
              );
            },
            tooltip: 'AI 投資顧問',
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
