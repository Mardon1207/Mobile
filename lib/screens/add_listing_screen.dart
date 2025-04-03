import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _image;
  bool _isLoading = false;

  final List<String> _regions = ['Toshkent', 'Samarqand', 'Buxoro', 'Andijon', 'Farg‘ona'];
  final Map<String, List<String>> _districts = {
    'Toshkent': ['Chilonzor', 'Yunusobod', 'Mirzo Ulug‘bek'],
    'Samarqand': ['Jomboy', 'Urgut', 'Pastdarg‘om'],
    'Buxoro': ['Vobkent', 'G‘ijduvon', 'Shofirkon'],
    'Andijon': ['Asaka', 'Marhamat', 'Xonobod'],
    'Farg‘ona': ['Oltiariq', 'Quva', 'Qo‘qon'],
  };

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitListing() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedRegion == null ||
        _selectedDistrict == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Barcha maydonlarni to‘ldiring!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool success = await ApiService.addListing(
      _titleController.text,
      _descriptionController.text,
      _priceController.text,
      _selectedRegion!,
      _selectedDistrict!,
      _image!,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("E’lon qo‘shildi!")),
      );
      Navigator.pop(context); // Orqaga qaytish
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xatolik yuz berdi!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yangi e’lon qo‘shish")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _image != null
                      ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                      : null,
                ),
                child: _image == null
                    ? Center(child: Icon(Icons.camera_alt, size: 50, color: Colors.grey))
                    : null,
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Sarlavha"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: "Tavsif"),
              maxLines: 3,
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: "Narx (UZS)"),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Viloyat"),
              value: _selectedRegion,
              items: _regions.map((region) {
                return DropdownMenuItem(value: region, child: Text(region));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegion = value;
                  _selectedDistrict = null;
                });
              },
            ),
            if (_selectedRegion != null) ...[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Tuman"),
                value: _selectedDistrict,
                items: _districts[_selectedRegion]!.map((district) {
                  return DropdownMenuItem(value: district, child: Text(district));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
              ),
            ],
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitListing,
                    child: Text("E’lon qo‘shish"),
                  ),
          ],
        ),
      ),
    );
  }
}
