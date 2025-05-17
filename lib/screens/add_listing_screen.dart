import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rentapp/screens/api_service.dart';

class AddListingScreen extends StatefulWidget {
  @override
  _AddListingScreenState createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedRegion;
  String? _selectedDistrict;
  String? _selectedCategory;
  File? _imageFile; // For non-web platforms
  String? _imageUrl; // For web platforms
  bool _isLoading = false;

  final List<String> _regions = [
    'Toshkent',
    'Samarqand',
    'Buxoro',
    'Andijon',
    'Farg‘ona',
    'Namangan',
    'Qashqadaryo',
    'Surxondaryo',
    'Jizzax',
    'Sirdaryo',
    'Navoiy',
    'Xorazm',
    'Qoraqalpog‘iston',
  ];
  final Map<String, List<String>> _districts = {
    'Toshkent': [
      'Chilonzor',
      'Yunusobod',
      'Mirzo Ulug‘bek',
      'Bektemir',
      'Sergeli',
      'Uchtepa',
    ],
    'Samarqand': [
      'Jomboy',
      'Urgut',
      'Pastdarg‘om',
      'Ishtixon',
      'Kattaqo‘rg‘on',
      'Payariq',
    ],
    'Buxoro': [
      'Vobkent',
      'G‘ijduvon',
      'Shofirkon',
      'Kogon',
      'Qorako‘l',
      'Romitan',
    ],
    'Andijon': [
      'Asaka',
      'Marhamat',
      'Xonobod',
      'Andijon shahri',
      'Baliqchi',
      'Oltinko‘l',
    ],
    'Farg‘ona': [
      'Oltiariq',
      'Quva',
      'Qo‘qon',
      'Marg‘ilon',
      'Rishton',
      'Farg‘ona shahri',
    ],
    'Namangan': [
      'Chortoq',
      'Pop',
      'Namangan shahri',
      'Uychi',
      'To‘raqo‘rg‘on',
      'Mingbuloq',
    ],
    'Qashqadaryo': [
      'Shahrisabz',
      'Qarshi',
      'Kitob',
      'Koson',
      'Chiroqchi',
      'Yakkabog‘',
    ],
    'Surxondaryo': [
      'Termiz',
      'Sherobod',
      'Denov',
      'Boysun',
      'Jarqo‘rg‘on',
      'Qumqo‘rg‘on',
    ],
    'Jizzax': [
      'Zomin',
      'G‘allaorol',
      'Jizzax shahri',
      'Do‘stlik',
      'Paxtakor',
      'Arnasoy',
    ],
    'Sirdaryo': [
      'Guliston',
      'Yangiyer',
      'Sirdaryo shahri',
      'Shirin',
      'Sayxunobod',
      'Mirzaobod',
    ],
    'Navoiy': [
      'Zarafshon',
      'Navoiy shahri',
      'Qiziltepa',
      'Konimex',
      'Uchquduq',
      'Tomdi',
    ],
    'Xorazm': ['Urganch', 'Xiva', 'Shovot', 'Bog‘ot', 'Gurlan', 'Yangibozor'],
    'Qoraqalpog‘iston': [
      'Nukus',
      'Mo‘ynoq',
      'Qo‘ng‘irot',
      'Chimboy',
      'To‘rtko‘l',
      'Kegeyli',
    ],
  };

  List<Map<String, String>> _categories =
      []; // Store categories as a list of maps
  bool _isCategoryLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      final categoryIds = await ApiService.fetchCategoriesId();

      setState(() {
        _categories = List.generate(categories.length, (index) {
          return {'name': categories[index], 'id': categoryIds[index]};
        });
        _isCategoryLoading = false;
        if (_categories.length >= 3) {
          _selectedCategory =
              _categories[2]['name']; // Pre-select the third category
        }
      });
    } catch (e) {
      print("Error fetching categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kategoriyalarni yuklashda xatolik yuz berdi!")),
      );
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // Handle image picking for web
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _imageUrl = result.files.first.bytes != null
              ? String.fromCharCodes(result.files.first.bytes!)
              : null; // Convert bytes to a string if needed
        });
      }
    } else {
      // Handle image picking for mobile/desktop
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitListing() async {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedRegion == null ||
        _selectedDistrict == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Barcha majburiy maydonlarni to‘ldiring!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the selected category ID
      final selectedCategoryId =
          _categories.firstWhere(
            (category) => category['name'] == _selectedCategory,
          )['id'];

      // Construct location
      final location = '$_selectedRegion, $_selectedDistrict';

      // Debug logs for parameters
      print("Title: ${_titleController.text}");
      print(
        "Description: ${_descriptionController.text.isEmpty ? null : _descriptionController.text}",
      );
      print("Price: ${_priceController.text}");
      print("Region: $_selectedRegion");
      print("District: $_selectedDistrict");
      print("Location: $location");
      print("Category ID: $selectedCategoryId");
      print("Image Path: ${_imageFile?.path}");

      bool success = await ApiService.addListing(
        _titleController.text,
        _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text, // Tavsif ixtiyoriy
        _priceController.text,
        location, // Pass location
        selectedCategoryId!, // Pass category ID
        _imageFile, // Image can be null
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("E’lon qo‘shildi!")));

        // Navigate to the HomeScreen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print("ApiService.addListing failed");
        throw Exception("Xatolik yuz berdi!");
      }
    } catch (e) {
      print("Error in _submitListing: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xatolik: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          "E’lon qo‘shish",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 22.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.08),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: _imageFile == null && _imageUrl == null
                          ? Colors.teal.shade100
                          : Colors.teal,
                      width: 2,
                    ),
                  ),
                  width: double.infinity,
                  height: 170,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickImage,
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : _imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_rounded,
                                      size: 48,
                                      color: Colors.teal.shade400,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Rasm tanlang",
                                      style: TextStyle(
                                        color: Colors.teal.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
                SizedBox(height: 22),
                Text(
                  "E’lon ma’lumotlari",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal.shade800,
                  ),
                ),
                SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.title_rounded, color: Colors.teal),
                    labelText: "Sarlavha",
                    labelStyle: TextStyle(color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.description_rounded,
                      color: Colors.teal,
                    ),
                    labelText: "Tavsif",
                    labelStyle: TextStyle(color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.attach_money_rounded,
                      color: Colors.teal,
                    ),
                    labelText: "Narx (UZS)",
                    labelStyle: TextStyle(color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.location_city_rounded,
                      color: Colors.teal,
                    ),
                    labelText: "Viloyat",
                    labelStyle: TextStyle(color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedRegion,
                  items: _regions
                      .map(
                        (region) => DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                      _selectedDistrict = null;
                    });
                  },
                ),
                if (_selectedRegion != null) ...[
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.map_rounded, color: Colors.teal),
                      labelText: "Tuman",
                      labelStyle: TextStyle(color: Colors.teal),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: _selectedDistrict,
                    items: _districts[_selectedRegion]!
                        .map(
                          (district) => DropdownMenuItem(
                            value: district,
                            child: Text(district),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    },
                  ),
                ],
                SizedBox(height: 12),
                _isCategoryLoading
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.category_rounded,
                            color: Colors.teal,
                          ),
                          labelText: "Kategoriya",
                          labelStyle: TextStyle(color: Colors.teal),
                          filled: true,
                          fillColor: Colors.teal.shade50,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.teal.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selectedCategory,
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category['name'],
                                child: Text(category['name']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                SizedBox(height: 28),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _submitListing,
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          label: Text(
                            "E’lon qo‘shish",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
