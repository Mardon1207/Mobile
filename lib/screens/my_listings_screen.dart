import 'package:flutter/material.dart';

class MyListingsScreen extends StatelessWidget {
  final List<dynamic> listings;

  MyListingsScreen({this.listings = const []});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          "Elonlarim",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: listings.isEmpty
          ? Center(
              child: Text(
                "Hozircha elonlar mavjud emas.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(listing['title'] ?? "No title"),
                    subtitle: Text(listing['description'] ?? "No description"),
                    trailing: Text(
                      "${listing['price'] ?? 0} so'm",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
