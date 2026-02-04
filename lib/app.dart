import 'package:flutter/material.dart';

import 'Screens/HomeScreen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Favorite Places',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 254, 211, 155),
        appBarTheme: AppBarTheme(backgroundColor: Colors.orangeAccent),
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          bodySmall: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
