import 'package:flutter/material.dart';
import 'package:product_app/screens/signup/signup.dart';
import 'screens/product_list_screen.dart';

void main() => runApp(const ProductApp());

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product CRUD App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
