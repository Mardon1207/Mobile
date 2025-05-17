import 'package:flutter/material.dart';

class MyRentalsScreen extends StatelessWidget {
  final List<dynamic> rentals;

  MyRentalsScreen({this.rentals = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          "Ijaralarim",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body:
          rentals.isEmpty
              ? Center(
                child: Text(
                  "Hozircha ijaralar mavjud emas.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  final rental = rentals[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(rental['title'] ?? "No title"),
                      subtitle: Text(rental['description'] ?? "No description"),
                      trailing: Text(
                        "${rental['price'] ?? 0} so'm",
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
