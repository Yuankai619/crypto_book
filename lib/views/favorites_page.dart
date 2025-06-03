import 'package:crypto_book/models/crypto_currency.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/favorite_view_model.dart';
import '../viewModels/crypto_view_model.dart';
import '../viewModels/auth_view_model.dart';
import '../widgets/coin_list_item.dart';
import 'detail_page.dart';
import 'auth/login_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // 在 initState 後安全地初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.isLoggedIn) {
        final favoriteViewModel = Provider.of<FavoriteViewModel>(
          context,
          listen: false,
        );
        favoriteViewModel.initializeFavorites();

        final cryptoViewModel = Provider.of<CryptoViewModel>(
          context,
          listen: false,
        );
        if (cryptoViewModel.coins.isEmpty) {
          cryptoViewModel.loadCoins();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏'),
        backgroundColor: Colors.grey[850],
        actions: [
          // 添加刷新按鈕
          Consumer<FavoriteViewModel>(
            builder: (context, favoriteViewModel, child) {
              return IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () => favoriteViewModel.refreshFavorites(),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (!authViewModel.isLoggedIn) {
            return _buildNotLoggedInView(context);
          }
          return _buildFavoritesView(context);
        },
      ),
    );
  }

  Widget _buildNotLoggedInView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            '請先登入以查看收藏',
            style: TextStyle(fontSize: 18, color: Colors.grey[400]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('登入'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesView(BuildContext context) {
    return Consumer2<FavoriteViewModel, CryptoViewModel>(
      builder: (context, favoriteViewModel, cryptoViewModel, child) {
        if (favoriteViewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  favoriteViewModel.error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    favoriteViewModel.clearError();
                    favoriteViewModel.refreshFavorites();
                  },
                  child: Text('重試'),
                ),
              ],
            ),
          );
        }

        if (favoriteViewModel.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  '還沒有收藏任何貨幣',
                  style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                ),
                SizedBox(height: 8),
                Text(
                  '在貨幣詳細頁面點擊愛心圖示來收藏',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // 如果幣種資料還沒載入完成，顯示載入中
        if (cryptoViewModel.isLoadingCoins) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('載入幣種資料中...'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            favoriteViewModel.refreshFavorites();
            await cryptoViewModel.loadCoins();
          },
          child: ListView.builder(
            itemCount: favoriteViewModel.favorites.length,
            itemBuilder: (context, index) {
              final favorite = favoriteViewModel.favorites[index];

              // 從 coins 列表中找到對應的 coin 資料
              CryptoCurrency? coin;
              try {
                coin = cryptoViewModel.coins.firstWhere(
                  (coin) => coin.id == favorite.coinId,
                );
              } catch (e) {
                // 如果在coins列表中找不到，創建一個基本的CryptoCurrency對象
                coin = CryptoCurrency(
                  id: favorite.coinId,
                  symbol: favorite.coinSymbol,
                  name: favorite.coinName,
                  imageUrl: favorite.imageUrl,
                  currentPrice: 0.0,
                  marketCap: 0.0,
                  priceChangePercentage24h: 0.0,
                );
              }

              return CoinListItem(
                coin: coin,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(coinId: favorite.coinId),
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
