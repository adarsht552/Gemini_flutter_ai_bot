import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Ensure this package is correctly added in pubspec.yaml
import 'package:gemini/geminiApi/Flutter_Gemini.dart';
import 'package:gemini/utils/text_field.dart'; // Ensure this package is correctly added in pubspec.yaml

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: 'AIzaSyBXXDVQL_QdJO1YwOCNqVD-wHZ9ATHVc7Y');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

