import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';


class ApiService {
  static const String baseUrl = "https://thawing-island-81474-bbf58f5cbf05.herokuapp.com"; 

  
   // ✅ Login funksiyasi
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login/'),
      body: jsonEncode({"username": username, "password": password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access']); // Tokenni saqlash
      await prefs.setString('username', username); // Foydalanuvchi ismini saqlash
      return true;
    } else {
      return false;
    }
  }

  // ✅ Logout funksiyasi
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Tokenni o‘chirish
    await prefs.remove('username'); // Foydalanuvchi ismini o‘chirish
  }


  // ✅ Ro‘yxatdan o‘tish funksiyasi
  static Future<bool> register(
      String firstName,
      String lastName,
      String email,
      String username,
      String password,
      String region,
      String district,
      String userType,
      File? profileImage) async {
    
    var url = Uri.parse("https://thawing-island-81474-bbf58f5cbf05.herokuapp.com/users/register/");
    var request = http.MultipartRequest("POST", url);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['email'] = email;
    request.fields['username'] = username;
    request.fields['password'] = password;
    request.fields['region'] = region;
    request.fields['district'] = district;
    request.fields['user_type'] = userType;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath("image", profileImage.path));
    }

    var response = await request.send();
    return response.statusCode == 201;
  }

  // E’lonlarni olish
static Future<List<dynamic>> fetchListings() async {
  final response = await http.get(
    Uri.parse('$baseUrl/listings/'),
    headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);  // JSON ma’lumotlarni qaytarish
  } else {
    throw Exception('Xatolik: ${response.statusCode}');
  }
}

  // To‘lov sessiyasini yaratish
  static Future<String?> createCheckoutSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/payments/create-checkout-session/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['session_id'];
    }
    return null;
  }
  static Future<bool> addListing(
    String title, String description, String price, String region, String district, File image) async {
    
    var url = Uri.parse("https://thawing-island-81474-bbf58f5cbf05.herokuapp.com/listings/create/");
    var request = http.MultipartRequest("POST", url);

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['region'] = region;
    request.fields['district'] = district;
    
    request.files.add(await http.MultipartFile.fromPath("image", image.path));

    var response = await request.send();
    return response.statusCode == 201;
  }

   // 🔹 Foydalanuvchi ma'lumotlarini olish
  static Future<void> fetchUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  if (token == null) {
    print("Token mavjud emas, iltimos, login qiling!");
    return;
  }

  var response = await http.get(
    Uri.parse("$baseUrl/users/profile/"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print("Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);

    print("Foydalanuvchi ma'lumotlari: $data");

    await prefs.setString('full_name', "${data['first_name'] ?? ''} ${data['last_name'] ?? ''}");
    await prefs.setString('email', data['email'] ?? "email@example.com");
    await prefs.setString('phone', data['phone_number'] ?? "None");
    await prefs.setString('region', data['region'] ?? "-");
    await prefs.setString('district', data['district'] ?? "-");
    await prefs.setString('profile_image', data['profile_image'] ?? "");
  } else {
    print("Xatolik: ${response.statusCode}");
  }
}
  
}
