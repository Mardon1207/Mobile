import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      // Django backend'dan sessiya ID olish
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/payments/create-checkout-session/"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        throw Exception("To‘lov sessiyasini yaratishda xatolik: ${response.body}");
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
      appBar: AppBar(title: Text("To‘lovlar")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _startPayment,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("To‘lovni boshlash"),
            ),
          ],
        ),
      ),
    );
  }
}
