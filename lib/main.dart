import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentapp/screens/home_screen.dart';
import 'package:rentapp/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Asinxron kodni ishlatish uchun
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: token == null ? LoginScreen() : HomeScreen(), // ✅ Agar token bo‘lsa, to‘g‘ri HomeScreen ga o‘tsin
  ));
}