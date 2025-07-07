import 'package:flutter/material.dart';
import 'app_colors.dart';
import './pages/home_flow.dart';

void main() => runApp(const ExpenseSplitterApp());

class ExpenseSplitterApp extends StatelessWidget {
  const ExpenseSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: light90,
        primaryColor: purple100,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: light100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: purple100,
            foregroundColor: light100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const HomeFlow(),
    );
  }
}
