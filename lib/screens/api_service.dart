import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl =
      "https://thawing-island-81474-bbf58f5cbf05.herokuapp.com";

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
      await prefs.setString(
        'username',
        username,
      ); // Foydalanuvchi ismini saqlash
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
    File? profileImage,
    String phone_number, // Added phone parameter
  ) async {
    var url = Uri.parse(
      "https://thawing-island-81474-bbf58f5cbf05.herokuapp.com/users/register/",
    );
    var request = http.MultipartRequest("POST", url);

    request.fields['first_name'] = firstName;
    request.fields['last_name'] = lastName;
    request.fields['email'] = email;
    request.fields['username'] = username;
    request.fields['password'] = password;
    request.fields['region'] = region;
    request.fields['district'] = district;
    request.fields['user_type'] = userType;
    request.fields['phone_number'] =
        phone_number; // Include phone in the request payload

    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", profileImage.path),
      );
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
      print(jsonDecode(response.body));
      return jsonDecode(response.body); // JSON ma’lumotlarni qaytarish
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
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['session_id'];
    }
    return null;
  }

  static Future<bool> addListing(
    String title,
    String? description,
    String price,
    String location, // Updated to include location
    String categoryId, // Updated to accept category ID
    File? image,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        print("Token is missing. Please log in.");
        return false;
      }

      final uri = Uri.parse('$baseUrl/listings/create/');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] =
          'Bearer $token'; // Add token to headers
      request.fields['title'] = title;
      request.fields['description'] = description ?? '';
      request.fields['price'] = price;
      request.fields['location'] = location; // Include location
      request.fields['category'] = categoryId; // Include category ID

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        return true;
      } else {
        // Log the response body for debugging
        final responseBody = await response.stream.bytesToString();
        print('Failed to add listing. Status code: ${response.statusCode}');
        print('Response body: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error in addListing: $e');
      return false;
    }
  }

  // 🔹 Foydalanuvchi ma'lumotlarini olish
  static Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      print("Token mavjud emas yoki bo'sh, iltimos, login qiling!");
      return;
    }

    try {
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

        if (data is! Map) {
          print("Xatolik: JSON format noto'g'ri!");
          return;
        }

        print("Foydalanuvchi ma'lumotlari: $data");

        // Ma'lumotlarni saqlash
        await prefs.setString(
          'full_name',
          data['full_name'] ?? data['username'] ?? "Foydalanuvchi",
        );
        await prefs.setString('email', data['email'] ?? "email@example.com");
        await prefs.setString('phone_number', data['phone_number'] ?? "None");
        await prefs.setString('region', data['region'] ?? "-");
        await prefs.setString('district', data['district'] ?? "-");
        await prefs.setString('profile_image', data['profile_image'] ?? "");
        await prefs.setString('user_type', data['user_type'] ?? "None");
      } else {
        print("Xatolik: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Istisno yuz berdi: $e");
    }
  }

  // 🔹 Kategoriyalarni olish
  static Future<List<String>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/listings/categories/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((category) => category['name'] as String).toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }

  static Future<List<String>> fetchCategoriesId() async {
    final response = await http.get(Uri.parse('$baseUrl/listings/categories/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((category) => category['id'].toString())
          .toList(); // Convert IDs to strings
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // 🔹 Xabarlarni olish
  static Future<List<dynamic>> getMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("Token is missing. Please log in.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/messages/'),
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch messages: ${response.statusCode}");
    }
  }

  static Future<void> sendMessage(String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("Token is missing. Please log in.");
    }

    final url = Uri.parse('$baseUrl/messages/');
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to send message: ${response.statusCode}");
    }
  }
}
