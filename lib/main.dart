import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home_page.dart';
import 'viewModels/crypto_view_model.dart';
import 'services/audio_service.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  runApp(
    ChangeNotifierProvider(
      create: (context) => CryptoViewModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioService.initialize();
      await Future.delayed(Duration(seconds: 1)); // Add a small delay
      await _audioService.playBackgroundMusic();
      if (kDebugMode) {
        print('Audio initialized and playing');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in audio initialization: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '幣冊',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          elevation: 0,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
        ),
      ),
      home: HomePage(),
    );
  }
}
