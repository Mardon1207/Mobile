import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rentapp/screens/api_service.dart';
import 'package:rentapp/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRegion;
  String? _selectedDistrict;
  String? _selectedUserType;
  File? _profileImage;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _regions = ['Toshkent', 'Samarqand', 'Buxoro', 'Andijon', 'Farg‘ona'];
  final Map<String, List<String>> _districts = {
    'Toshkent': ['Chilonzor', 'Yunusobod', 'Mirzo Ulug‘bek'],
    'Samarqand': ['Jomboy', 'Urgut', 'Pastdarg‘om'],
    'Buxoro': ['Vobkent', 'G‘ijduvon', 'Shofirkon'],
    'Andijon': ['Asaka', 'Marhamat', 'Xonobod'],
    'Farg‘ona': ['Oltiariq', 'Quva', 'Qo‘qon'],
  };

  final List<String> _userTypes = ['renter', 'owner'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedUserType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Iltimos, barcha maydonlarni to‘ldiring!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await ApiService.register(
      _firstNameController.text,
      _lastNameController.text,
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
      _selectedRegion ?? "",
      _selectedDistrict ?? "",
      _selectedUserType ?? "renter",  // ✅ To‘g‘rilandi
      _profileImage,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ro‘yxatdan o‘tishda xatolik!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Ro‘yxatdan o‘tish"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null ? Icon(Icons.camera_alt, size: 40, color: Colors.blue) : null,
                ),
              ),
              SizedBox(height: 15),
              _buildTextField(_firstNameController, "Ism", Icons.person),
              _buildTextField(_lastNameController, "Familiya", Icons.person_outline),
              _buildTextField(_emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress),
              _buildTextField(_usernameController, "Foydalanuvchi nomi", Icons.account_circle),
              _buildTextField(_passwordController, "Parol", Icons.lock, obscureText: true),
              
              _buildDropdown("Foydalanuvchi turi", _userTypes, _selectedUserType, (value) {
                setState(() {
                  _selectedUserType = value;
                });
              }),

              _buildDropdown("Viloyat", _regions, _selectedRegion, (value) {
                setState(() {
                  _selectedRegion = value;
                  _selectedDistrict = null;
                });
              }),

              if (_selectedRegion != null)
                _buildDropdown("Tuman", _districts[_selectedRegion] ?? [], _selectedDistrict, (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                }),

              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Ro‘yxatdan o‘tish", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedValue,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
