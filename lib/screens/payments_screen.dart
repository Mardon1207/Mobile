import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentsScreen extends StatefulWidget {
  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _isLoading = false;
  String _statusMessage = "Hali to‘lov qilinmagan.";

  Future<void> _startPayment() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "To‘lov sessiyasi yaratilmoqda...";
    });

    try {
      // Tokenni olish
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token') ?? "test_token";
      print("Token: $token"); // Tokenni chop etish
      print(token);
      // Django backend'dan sessiya ID olish
      final response = await http.post(
        Uri.parse(
          "https://thawing-island-81474-bbf58f5cbf05.herokuapp.com/payments/create-checkout-session/",
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Tokenni qo‘shish
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          "To‘lov sessiyasini yaratishda xatolik: ${response.body}",
        );
      }

      final data = jsonDecode(response.body);
      final sessionId = data["sessiya_id"];

      // Stripe orqali checkout ochish
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: sessionId,
          merchantDisplayName: "RentApp",
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      setState(() {
        _statusMessage = "To‘lov muvaffaqiyatli amalga oshirildi!";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Xatolik: ${e.toString()}";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To‘lovlar"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
                child:
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.deepPurple)
                        : Text(
                          "To‘lovni boshlash",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
