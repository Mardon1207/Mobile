import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentapp/screens/listings_screen.dart';
import 'package:rentapp/screens/login_screen.dart';
import 'package:rentapp/screens/profile_screen.dart';
import 'package:rentapp/screens/payments_screen.dart';
import 'package:rentapp/screens/add_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _token;
  String? _role; // "renter" yoki "owner"

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _role = prefs.getString('role'); // Foydalanuvchi roli ("owner" yoki "renter")
    });
  }

  // Asosiy sahifa ekrani bo'limlari
  List<Widget> _widgetOptions() {
    List<Widget> pages = [
      ListingsScreen(),
      PaymentsScreen(), // To‘lovlar bo‘limi har ikkala rol uchun
    ];
    
    if (_role == "owner") {
      pages.insert(1, AddListingScreen()); // Agar owner bo‘lsa, "E’lon qo‘shish" sahifasi chiqadi
    }
    
    return pages;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openProfileScreen() {
    if (_token == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ProfileScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1),
                end: Offset(0, 0),
              ).animate(animation),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = _widgetOptions();
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Asosiy sahifa"),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: _openProfileScreen,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'E’lonlar'),
          if (_role == "owner") 
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'E’lon qo‘shish'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'To‘lovlar'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
