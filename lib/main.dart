import 'package:flutter/material.dart';
import 'views/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
