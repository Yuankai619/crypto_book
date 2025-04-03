# Cryptocurrency Information App with Flutter: 幣冊
## Demo video
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/sg1v-Pa1S1I/0.jpg)](https://www.youtube.com/watch?v=sg1v-Pa1S1I)

## Medium link
https://medium.com/@lyuankai/幣冊-虛擬貨幣介紹app-4df9e93fbdbb

## Architecture: MVVM Pattern

One of the first decisions I made was to implement the Model-View-ViewModel (MVVM) pattern to achieve clean separation of concerns:

- **Models**: `CryptoCurrency` and `Category` classes represent the data structure
- **ViewModels**: `CryptoViewModel` manages the business logic and data processing
- **Views**: Screens like `HomePage`, `DetailPage`, and widgets

This architecture makes the codebase more maintainable and testable by separating UI elements from business logic.

## Data Source: CoinGecko API

I chose CoinGecko's API for its comprehensive cryptocurrency data and free tier that provides:
- Market data for thousands of cryptocurrencies
- Detailed information about each currency
- Category information

Implementation in the `ApiService` class:

```dart
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
```

## State Management with Provider

I implemented Provider for state management to efficiently propagate data changes throughout the widget tree:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => CryptoViewModel(),
      child: MyApp(),
    ),
  );
}
```

This allows components to listen for data changes through the `CryptoViewModel`.

## Advanced UI Components

### TabBar for Content Organization

The `HomePage` implements a TabBar to organize content into "All Coins" and "Categories" sections:

```dart
DefaultTabController(
  length: 2,
  child: Scaffold(
    appBar: AppBar(
      // ...
      bottom: TabBar(tabs: [Tab(text: '全部'), Tab(text: '類別')]),
    ),
    body: TabBarView(
      children: [_buildAllCoinsTab(), _buildCategoriesTab()],
    ),
  ),
)
```

### ListView for Efficient Scrolling

For displaying the list of cryptocurrencies, I used ListView.builder for efficient memory management:

```dart
ListView.builder(
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
)
```

### GridView for Category Display

Categories are displayed in a grid layout for visual appeal:

```dart
GridView.builder(
  padding: EdgeInsets.all(16),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.2,
  ),
  // ...
)
```

## Background Music Integration

One unique feature is background music, implemented using the AudioPlayers package:

```dart
class AudioService {
  // ...
  Future<void> playBackgroundMusic() async {
    if (!_isInitialized) await initialize();
    if (_isMusicEnabled) {
      try {
        await _audioPlayer.play(
          AssetSource('music/Isaac DaBom - Crosswalk Bounce.mp3'),
        );
        // ...
      } catch (e) {
        // ...
      }
    }
  }
}
```

The music can be toggled in the UI with an intuitive button in the app bar.

## Navigation Between Screens

I implemented the Navigator API for seamless transitions between screens:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailPage(coinId: coin.id),
  ),
);
```

## Error Handling and User Feedback

The app implements robust error handling with user-friendly feedback:

```dart
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
```
