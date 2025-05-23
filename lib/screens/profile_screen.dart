import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rentapp/screens/login_screen.dart';
import 'package:rentapp/screens/api_service.dart'; // To'g'ri import

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _fullName;
  String? _email;
  String? _profileImage;
  String? _phone;
  String? _region;
  String? _district;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Foydalanuvchi ma'lumotlarini API orqali yangilash
      await ApiService.fetchUserData();
    } catch (e) {
      print("Foydalanuvchi ma'lumotlarini yuklashda xatolik: $e");
      print("Xatolik tafsilotlari: ${e.toString()}");
    }

    setState(() {
      _fullName = prefs.getString('full_name') ?? "Foydalanuvchi";
      _email = prefs.getString('email') ?? "email@example.com";
      _phone = prefs.getString('phone') ?? "None";
      _region = prefs.getString('region') ?? "-";
      _district = prefs.getString('district') ?? "-";
      _userType = prefs.getString('user_type') ?? "None";

      // Agar rasm null yoki bo‘sh bo‘lsa, default rasm ishlatish
      String? image = prefs.getString('profile_image');
      _profileImage =
          (image != null && image.isNotEmpty)
              ? image
              : "https://your-default-image.com/default.jpg";
    });

    // Konsolga ma'lumotlarni yozib ko'rish
    print("Full Name: $_fullName");
    print("Email: $_email");
    print("Phone: $_phone");
    print("Region: $_region");
    print("District: $_district");
    print("Profile Image: $_profileImage");
    print("User Type: $_userType");
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body:
          _fullName == null || _email == null || _profileImage == null
              ? Center(
                child: CircularProgressIndicator(),
              ) // Ma'lumotlar yuklanayotganini ko'rsatish
              : Column(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(_profileImage!),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _fullName!,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _email!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 15,
                          top: 40,
                          child: IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _logout,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.blue),
                    title: Text("Telefon raqami"),
                    subtitle: Text(_phone ?? "None"),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.blue),
                    title: Text("Hudud"),
                    subtitle: Text("${_region ?? '-'}, ${_district ?? '-'}"),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.blue),
                    title: Text("Sozlamalar"),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Sozlamalar hali mavjud emas")),
                      );
                    },
                  ),
                ],
              ),
    );
  }
}
