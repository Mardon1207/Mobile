import 'package:flutter/material.dart';
import 'package:rentapp/screens/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentapp/screens/listings_screen.dart';
import 'package:rentapp/screens/login_screen.dart';
import 'package:rentapp/screens/profile_screen.dart';
import 'package:rentapp/screens/payments_screen.dart';
import 'package:rentapp/screens/add_listing_screen.dart';
import 'package:rentapp/screens/chat_screen.dart';
import 'package:rentapp/screens/my_rentals_screen.dart'; // Import for the new screen
import 'package:rentapp/screens/my_listings_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex =
      0; // _selectedIndex o'zgaruvchisi e'lon qilindi va boshlang'ich qiymat berildi

  String? _fullName;
  String? _email;
  String? _profileImage;
  String? _phone;
  String? _region;
  String? _district;
  String? _userType;
  String? _token;
  String? _role; // "renter" yoki "owner"
  bool isLoading = true; // Yuklanish holati
  List<dynamic> myRentals = []; // Shared list for rentals

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Saqlangan rolni tekshirish
    try {
      // Foydalanuvchi ma'lumotlarini API orqali yangilash
      await ApiService.fetchUserData();
    } catch (e) {
      print("Foydalanuvchi ma'lumotlarini yuklashda xatolik: $e");
      print("Xatolik tafsilotlari: ${e.toString()}");
    }
    setState(() {
      _token =
          prefs.getString('token') ?? "test_token"; // Tokenni auto-fill qilish

      _fullName = prefs.getString('full_name') ?? "Foydalanuvchi";
      _email = prefs.getString('email') ?? "email@example.com";
      _phone = prefs.getString('phone') ?? "None";
      _region = prefs.getString('region') ?? "-";
      _district = prefs.getString('district') ?? "-";
      _userType = prefs.getString('user_type') ?? "None";
      String? image = prefs.getString('profile_image');
      _profileImage =
          (image != null && image.isNotEmpty)
              ? image
              : "https://your-default-image.com/default.jpg"; // Default rasm to'g'ri o'rnatildi

      isLoading = false; // Yuklanish tugadi
      print("Loaded token: $_token"); // Tokenni tekshirish uchun log
      print("Loaded role: $_role"); // Roleni tekshirish uchun log
      print("Full Name: $_fullName");
      print("Email: $_email");
      print("Phone: $_phone");
      print("Region: $_region");
      print("District: $_district");
      print("Profile Image: $_profileImage");
      print("User Type: $_userType");
    });
    String? savedRole = _userType;
    // Qo'shimcha log
    if (savedRole == null) {
      print("Role qiymati saqlanmagan. Default qiymat: renter");
    } else {
      print("Role qiymati saqlangan: $savedRole");
    }
  }

  // Asosiy sahifa ekrani bo'limlari
  List<Widget> _widgetOptions() {
    List<Widget> pages = [
      ListingsScreen(
        myRentals: myRentals,
        showAppBar: false, // Disable AppBar for ListingsScreen
      ),
      if (_userType == "owner")
        AddListingScreen(), // "E’lon qo‘shish" faqat owner uchun
      if (_userType == "owner")
        MyListingsScreen(
          listings: myRentals, // Pass owner's listings
        ), // "Elonlarim" for owners
      if (_userType == "renter")
        MyRentalsScreen(
          rentals: myRentals,
        ), // "Ijaralarim" for renters
      PaymentsScreen(), // To‘lovlar bo‘limi har ikkala rol uchun
      ChatScreen(), // Chat sahifasi qo'shildi
    ];

    return pages;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Selected tab index: $index"); // Log qo'shildi
  }

  void _openProfileScreen() {
    if (_token == null || _token!.isEmpty) {
      print("Token mavjud emas, LoginScreen ochilmoqda."); // Log qo'shildi
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      print("Token mavjud, ProfileScreen ochilmoqda."); // Log qo'shildi
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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0,
          title: Text(
            "Yuklanmoqda...",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Widget> pages = _widgetOptions();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          "IJARACHI",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: _openProfileScreen,
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'E’lonlar joyi',
          ),
          if (_userType == "owner")
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'E’lon qo‘shish joyi',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: _userType == "owner" ? 'Elonlarim' : 'Ijaralarim', // Dynamic label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'To‘lovlar joyi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
